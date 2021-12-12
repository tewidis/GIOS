# Distributed Shared Memory

Distributed Shared Memory Overview

    * Must decide placement
        + Place memory (pages) close to relevant processes
    * Must decide migration
        + When to copy memory (pages) from remote to local
    * Must decide sharing rules
        * Ensure memory operations are properly ordered

DFS Review

    * Clients
        + Send requests to file service
    * Caching
        + Improve performance (seen by clients) and scalability (supported by
        servers)
    * Servers
        + Own and manage state (files)
        + Provide service (file access)
    * How do we coordinate access of shared state among multiple servers?

Peer Distributed Applications

    * Each node...
        + "Owns" state (state is locally stored or generated)
        + Provides service
        + All nodes are "peers"
    * Examples: big data analytics, web searches, content sharing, or
    distributed shared memory (DSM)
    * In "peer-to-peer," overall management is done by all nodes

Distributed Shared Memory

    * Each node...
        + "Owns" state -> memory
        + Provides service
            - Memory reads/writes from any node
            - Consistency protocol
    * Permits scaling beyond single machine limits
        + More "shared" memory at lower cost
        + Slower overall memory access for remote memory
        + Commodity interconnect technologies offer low latency among nodes
            - RDMA: Remote Direct Memory Access

| ![dsm_overview](images/dsm_overview.png) |
|:--:|
| Overview of Distributed Shared Memory |

Hardware vs Software DSM

    * Hardware supported (expensive!)
        + Relies on interconnect
        + OS manages larger physical memory
        + NICs translate remote memory accesses to messages
        + NICs involved in all aspects for memory management; support atomics...
    * Software supported
        + Everything done by software
        + OS, or language runtime
    * According to the paper "Distributed Shared Memory: Concepts and Systems",
    what is a common task that's implemented in software in hybrid (HW+SW) DSM
    implementations?
        + Prefetch pages - Easier to implement in software
        + Address translation - Easier to implement in hardware
        + Triggering invalidations - Easier to implement in hardware

DSM Design: Sharing Granularity

    * Cache line granularity? (used in SMP systems)
        + Overheads too high for DSM
    * Variable granularity
        + Overheads too high for small variables (integers)
    * Page granularity (OS-level)
    * Object granularity (language runtime)
    * Beware of false sharing
        + Process 1 writes X, process 2 writes Y; both to separate locations
            - If X and Y are on the same page, coherence overhead is incurred
            - Try to put variables on separate pages (programmer or compiler)

DSM Design: Access Algorithm

    * Application access algorithm
        + Single reader/single writer (SRSW)
        + Multiple readers/single writer (MRSW)
        + Multiple readers/multiple writers (MRMW)
            - Writes must be correctly ordered to present a consistent view

DSM Design: Migration vs Replication

    * DSM performance metric == access latency
    * Migration: Copy state from one node to another as needed
        + Makes sense for SRSW
        + Requires data movement
        + Copying state for a single R/W is expensive (not amortized)
    * Replication: State is copied across multiple (potentially all) nodes
        + More general
        + Requires consistency management
        + Caching provides lower latency (proportional to number of copies)
    * If access latency (performance) is a primary concern, which of the 
    following techniques would be best to use in your DSM design?
        + Migration - No (only okay for SRSW)
        + Caching - Yes (for many "concurrent" writes, overheads may be high!)
        + Replication - Yes (for many "concurrent" writes, overheads may be high!)

DSM Design: Consistency Management

    * DSM is analogous to shared memory in shared multiprocessors
    * In SMP
        + Write invalidate - Update in one cache marks other caches as invalid
        + Write update - Update in one cache modifies other caches
        + Coherence operations triggered on each write (overhead too high)
    * In DSM
        + Push invalidations when data is written to...
            - Proactive/eager/pessimistic
            - Expect that updated state is needed immediately
        + Pull modifications periodically...
            - On demand (reactive/lazy/optimistic)
            - Expect that updated state is not needed immediately
        + These methods get triggered depending on the consistency model for the
        shared state

DSM Architecture

    * Page-based, OS-supported
        + Distributed nodes, each with own local memory contribution
        + Pool of pages from all nodes
        + Each page has ID, page frame number
    * If MRMW...
        + Need local caches for performance (latency)
        + Home (or manager) node drives coherence operations
        + All nodes responsible for part of distributed memory (state) management
        + Each node contributes part of memory pages to DSM
        + Home node manages accesses and tracks page ownership
    * "Home" node
        + Keeps state: pages accessed, modifications, caching enabled/disabled,
        locked...
        + Current "owner" (owner may not be home node)
    * Explicit replicas
        + Created for load balancing, performance, or reliability
        + Home/manager node controls management
        + Data centers triplicate shared state (original machine, nearby machine
        (same rack), remote machine (different rack or data center)

| ![architecture](images/dsm_architecture.png) |
|:--:|
| DSM Architecture |

Summarizing DSM Architecture

    * Page-based DSM
        + Each node contributes part of memory pages to DSM
        + Need local caches for performance (latency)
        + All nodes responsible for part of distributed memory
        + Home node manages accesses and tracks page ownership
        + Explicit replication possible for load balancing, performance, or
        reliability

Indexing Distributed State

    * DSM Metadata
        + Address == node ID + page frame number
        + Node ID == "home" node
    * Global map (replicated)
        + Object (page) ID -> manager node ID
    * Global mapping table
        + Object ID -> index into mapping table -> manager node
    * Metadata for local pages (partitioned)
        + Per-page metadata is distributed across managers

Implementing DSM

    * Problem: DSM must "intercept" accesses to remote DSM state
        + To send remote messages requesting access
        + To trigger coherence messages
        + Overheads should be avoided for local, non-shared state (pages)
        + Dynamically "engage" and "disengage" DSM when necessary
    * Solution: Use hardware MMU support
        + Trap into OS if mapping invalid or access not permitted
        + Remote address mapping -> trap and pass to DSM to send message
        + Cached content -> trap and pass to DSM to perform necessary coherence
        operations
        + Other MMU information is useful (dirty page)

What is a Consistency Model?

    * Consistency model == agreement between memory (state) and upper software
    layers
    * "Memory behaves correctly if and only if software follows specific rules"
        + Memory (state) guarantees to behave correctly...
            - Access ordering
            - Propagation/visibility of updates
        + Software might need additional atomic operations to provide other
        guarantees
    * Timeline notation
        + R_m1(x) == X was read from memory location m1
        + W_m1(y) == Y was written to memory location m1
        + At t=0, all memory is set to 0

| ![timeline](images/dsm_timeline_model.png) |
|:--:|
| DSM Architecture |

Strict Consistency

    * Strict consistency: Updates visible everywhere immediately
    * In practice, even on single SMP, no guarantees on order without extra
    locking and synchronization
    * In distributed systems, latency and message reorder/loss make this even 
    harder
    * Impossible to guarantee, nice theoretical model

| ![strict](images/dsm_strict_consistency.png) |
|:--:|
| Strict Consistency |

Sequential Consistency

    * Memory updates from different processes may be arbitrarily interleaved
    * All process will see the same interleaving (might not be the actual order
    that they occurred though)

| ![sequential](images/dsm_sequential_consistency.png) |
|:--:|
| Sequential Consistency |

Causal Consistency

    * Software detects potential relationships between writes
        + Guarantees that the order of these relationships will be correct
    * Does not permit writes from a single process to be arbitrarily reordered
    * For "concurrent" writes (not causally related), no guarantees

| ![causal](images/dsm_causal_consistency.png) |
|:--:|
| Causal Consistency |

Weak Consistency

    * A write to a memory location isn't necessarily predicated on the read that
    happened prior, as causal consistency assumes
    * Weak synchronization doesn't make the same assumption
    * Instead, introduces synchronization points
    * Synchronization points: Operations that are available (R,W,sync)
        + All updates prior to a synchronization point will be visible
        + No guarantee what happens in between
        + Must be called by process performing update and processes that need to
        see the update
    * Variations
        + Single synchronization operation (sync)
        + Separate sync per subset of state (page)
        + Separate "entry/acquire" vs "exit/release" operations
    * Pro: Try to limit data movement and coherence operations
    * Con: Maintain extra state for additional operations

| ![weak](images/dsm_weak_consistency.png) |
|:--:|
| Weak Consistency |
