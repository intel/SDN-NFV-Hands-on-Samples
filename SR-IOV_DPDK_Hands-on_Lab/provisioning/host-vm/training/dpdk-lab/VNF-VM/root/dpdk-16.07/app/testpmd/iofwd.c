/*-
 *   BSD LICENSE
 *
 *   Copyright(c) 2010-2016 Intel Corporation. All rights reserved.
 *   All rights reserved.
 *
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in
 *       the documentation and/or other materials provided with the
 *       distribution.
 *     * Neither the name of Intel Corporation nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdint.h>
#include <unistd.h>
#include <inttypes.h>

#include <sys/queue.h>
#include <sys/stat.h>

#include <rte_common.h>
#include <rte_byteorder.h>
#include <rte_log.h>
#include <rte_debug.h>
#include <rte_cycles.h>
#include <rte_memory.h>
#include <rte_memzone.h>
#include <rte_launch.h>
#include <rte_eal.h>
#include <rte_per_lcore.h>
#include <rte_lcore.h>
#include <rte_atomic.h>
#include <rte_branch_prediction.h>
#include <rte_ring.h>
#include <rte_memory.h>
#include <rte_memcpy.h>
#include <rte_mempool.h>
#include <rte_mbuf.h>
#include <rte_interrupts.h>
#include <rte_pci.h>
#include <rte_ether.h>
#include <rte_ethdev.h>
#include <rte_string_fns.h>

#include "testpmd.h"

/*
 * Forwarding of packets in I/O mode.
 * Forward packets "as-is".
 * This is the fastest possible forwarding operation, as it does not access
 * to packets data.
 */
static void
pkt_burst_io_forward(struct fwd_stream *fs)
{
        struct rte_mbuf *pkts_burst[MAX_PKT_BURST];
        uint16_t nb_rx;
        uint16_t nb_tx;
        uint32_t retry;

#ifdef RTE_TEST_PMD_RECORD_CORE_CYCLES
        uint64_t start_tsc;
        uint64_t end_tsc;
        uint64_t core_cycles;
#endif

#ifdef RTE_TEST_PMD_RECORD_CORE_CYCLES
        start_tsc = rte_rdtsc();
#endif

        /********************************
         * DPDK_HANDS_ON_LAB: Step #1
         *
         * Receive a burst of packets and forward them.
         *
         * HINTS:
         * 1. The number of packets per burst was defined on the testpmd
         *      command-line as 64 and can be found in the global variable
         *      nb_pkt_per_burst. (See /root/run_testpmd.sh)
         * 2. Rx and Tx have 1 queue each
         * 3. See the definition of rte_eth_rx_burst () in
         *      $DPDK_HOME/lib/librte_ether/rte_ethdev.h
         * 4. The fwd_stream struct input parameter has rx_port and rx_queue members
         * 5. If all else fails, just uncomment these two lines of code:
         *      nb_rx = rte_eth_rx_burst(fs->rx_port, fs->rx_queue,
         *              pkts_burst, nb_pkt_per_burst);
         */


        /********************************
         * DPDK_HANDS_ON_LAB: Step #2
         *
         * If the number of packets we just received is zero, then we
         * are done because we have nothing to forward, so exit the function.
         *
         * HINTS:
         * 1. The rte_eth_rx_burst() function returns the number of packets
         *      that were received.
         * 2. The unlikely() macro is a compiler hint that indicates that
         *      the clause is unlikely to be true.
         * 3. If all else fails, just uncomment these two lines of code:
         *      if (unlikely(nb_rx == 0))
         *              return;
         */

        fs->rx_packets += nb_rx;

#ifdef RTE_TEST_PMD_RECORD_BURST_STATS
        fs->rx_burst_stats.pkt_burst_spread[nb_rx]++;
#endif

        /********************************
         * DPDK_HANDS_ON_LAB: Step #3
         *
         * Transmit a burst of packets
         *
         * HINTS:
         * 1. See the definition of rte_eth_tx_burst () in
         *      $DPDK_HOME/lib/librte_ether/rte_ethdev.h
         * 4. The fwd_stream struct input parameter has tx_port and tx_queue members
         * 5. If all else fails, just uncomment these two lines of code:
         *      nb_tx = rte_eth_tx_burst(fs->tx_port, fs->tx_queue,
         *              pkts_burst, nb_rx);
         */

        /*
         * Retry if necessary
         */
        if (unlikely(nb_tx < nb_rx) && fs->retry_enabled) {
                retry = 0;
                while (nb_tx < nb_rx && retry++ < burst_tx_retry_num) {
                        rte_delay_us(burst_tx_delay_time);
                        nb_tx += rte_eth_tx_burst(fs->tx_port, fs->tx_queue,
                                        &pkts_burst[nb_tx], nb_rx - nb_tx);
                }
        }
        fs->tx_packets += nb_tx;
#ifdef RTE_TEST_PMD_RECORD_BURST_STATS
        fs->tx_burst_stats.pkt_burst_spread[nb_tx]++;
#endif
        if (unlikely(nb_tx < nb_rx)) {
                fs->fwd_dropped += (nb_rx - nb_tx);
                do {
                        rte_pktmbuf_free(pkts_burst[nb_tx]);
                } while (++nb_tx < nb_rx);
        }
#ifdef RTE_TEST_PMD_RECORD_CORE_CYCLES
        end_tsc = rte_rdtsc();
        core_cycles = (end_tsc - start_tsc);
        fs->core_cycles = (uint64_t) (fs->core_cycles + core_cycles);
#endif
}

struct fwd_engine io_fwd_engine = {
        .fwd_mode_name  = "io",
        .port_fwd_begin = NULL,
        .port_fwd_end   = NULL,
        .packet_fwd     = pkt_burst_io_forward,
};
