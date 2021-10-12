# Thread Performance Considerations

Which model is better?

    * When comparing two threading models, consider what metrics to apply
        + Total execution time
        + Average time to complete an order
    * Boss-Worker Model
        + 6 workers, 120ms per order
            - Total execution time = 120ms * 3 batches = 360ms
            - Average execuation time = ((5*120)+(5*240)+360) / 11 = 196ms
    * Pipeline Model
        + 20 ms per pipeline stage
            - Total execution time = 120 + (10 * 20) = 320ms
            - Average execution time = (120+140+...+320) / 11 = 220ms

Are threads useful?
    
    * Parallelization -> Speed up
    * Specialization -> Hot cache
    * Efficiency -> Lower memory requirement and cheaper synchronization
    * Threads hide latency of IO operations (single CPU)
    * But what is useful?
        + For matrix multiply -> Execution time
        + For a web service application -> Client requests/time, response time
            - Could be average, min, max, 95%
        + For hardware -> Higher utilization (CPU)
        + Evaluate the answer based on relevant metrics

Metrics for Operating Systems/Toy Shops

    * Throughput
        + How many toys per hour?
        + Process completion rate
    * Response Time
        + Average time to react to a new order
        + Average time to respond to input (mouse click)
    * Utilization
        + Percent of workbenches in use over time
        + Percentage of CPU

Performance Metrics

    * Metrics - A measurement standard
        + Measurable and/or quantifiable property... (Execution time)
        + of the system we're interested in... (Software implementation of a problem)
        + that can be used to evaluate system behavior (improvement vs other implementations)
    * Execution time, throughput, request rate, CPU utilization, wait time, 
    platform efficiency, performance/dollar, performance/Watt, percentage of SLA
    violations, client-perceived performance, aggregate performance, average
    resource usage
    * Obtain metrics by experiments with real software deployment, machines, workload
        + Not always possible, so use 'toy' experiments representative of realistic settings
        + Testbed - Simulation occurring using realistic settings
    * Usefulness of threads depends on the metrics and workload we care about
        + Different number of toy orders -> different implementation of toy shop
        + Different type of graph -> Different shortest path algorithm
        + Different file patterns -> Different file system
        + It always depends, but this is never a valid answer

Multiprocess vs Multithreaded

    * Use the example of a web server (concurrently processing requests)
    * Steps in a simple web server
        1. Client/browser sends a request
        2. Web server accepts the request
        3. Server accepts connection
        4. Server reads the request
        5. Server parses the request
        6. Server finds the file
        7. Server computes the header
        8. Server sends the header
        9. Server reads the file and send the data
        10. Server closes the connection
    * Multiprocessing approach
        + Pro: Simple implementation
        + Con: Allocate memory for each
        + Con: Costly context switching
        + Con: Hard/costly to maintain shared state
        + Con: Tricky to set up ports
    * Multithreaded approach
        + Pro: Shared address space
        + Pro: Shared state
        + Pro: Cheap context switch
        + Con: Implementation is more difficult
        + Con: Explicitly handle synchronization
        + Con: Requires underlying support for threads
    * Event-Driven Model
        + Single address space, process, thread of control
        + Event dispatcher waits for an event to occur and invokes a handler
        + Dispatcher == State machine
        + Calling a handler == jumping to the code
            - Runs to completion, if it needs to block, initiate blocking 
            operation and pass control to dispatch loop

| ![eventdriven](images/event_driven_model.png) |
|:--:|
| Event-Driven Model |

Concurrency in the Event-Driven Model

    * MP and MT: 1 request per execution context
    * Event-driven: Many requests interleaved in an execution context
        + Single thread switches among processing of different requests
        + Dispatcher moves requests between handlers as needed
    * What is the benefit?
        + Can hide latency by context switching
        + If there's no need to context switch, cycles are spent being productive
        + Process request until wait necessary then switch to another request
        + Multiple CPUs -> Multiple event-driven processes
    * How is it implemented?
        + Sockets -> Network, Files -> Disk
        + File descriptors are used for both
        + Event == Input on file descriptor (FD)
        + Use select(), poll(), epoll() to pick a file descriptor
    * Benefits
        + Single address space, single flow of control
        + Smaller memory requirement
        + No context switching
        + No synchronization
    * Helper Threads and Processes
        + A blocking request/handler will block the entire process
        + Use asynchronous I/O operations
            - Process/thread makes system call
            - OS obtains all relevent info from stack, and either learns where 
            to return results, or tells caller where to get results later
            - Process/thread can continue
            - Requires support from kernel (threads) and/or device (DMA)
            - Fits nicely with event-driven model
        + What if asynchronous calls are not available?
            - Helpers are designated for blocking I/O operations only
            - Pipe/socket based communcation with event dispatcher (select/poll)
            - Helper blocks, but main event loop (and process) will not
        + AMPED - Asymmetric Multi-Process Event-Driven Model
        + AMTED - Asymmetric Multi-Threaded Event-Driven Model
        + Pro: Resolves portability limitations of basic event-driven model
        + Pro: Smaller footprint than regular worker thread
        + Con: Applicability of certain classes of applications
        + Con: Event routing on multi-CPU systems

Flash Web Server

    * Event-driven webserver (AMPED) with asymmetric helper processes
    * Helpers used for disk reads
    * Pipes used for communication with dispatcher
    * Helper reads file in memory (via mmap)
    * Dispatcher checks (via mincore) if pages are in memory to decide 'local'
    handler or helper
        + Results in large savings
    * Additional optimizations
        + Application-level caching for both data and computation
        + Alignment for DMA
        + Use of DMA with scatter-gather -> vector I/O operations

Apache Web Server

    * Core -> Basic server skeleton
    * Modules -> Per functionality (security, content management, HTTP requests)
    * Flow of control is similar to event-driven model, but Apache is a 
    combination of multiprocess and multithread
        + Each process == Boss/worker with dynamic thread pool
        + Number of processes can be dynamically adjusted

Experimental Methodology

    * What systems are you comparing? Define comparison points
        + Multiprocess (each process single thread)
        + Multithreaded (boss-worker)
        + Single process event-driven (SPED)
        + Zeus (SPED with 2 processes)
        + Apache (v1.3.1, multiprocess)
        + Compare against Flash (AMPED model)
            - Same optimizations except for Apache
    * What workloads will be used? Define inputs
        + Realistic request workload
            - Distribution of web page accesses over time
            - Trace-based (gathered from real web servers) - Reproducible
    * How will you measure performance? Define metrics
        + Bandwidth = Total bytes transferred from files / total time
        + Connection rate = total client connections / total time
        + Evaluated as a function of file size
            - Larger file size -> ammortize per connection cost -> higher bandwidth
            - Also requires more work per connection -> lower connection rate

Experimental Results (Best Case)

    * Synthetic load: Number of requests (N) for same file (best case)
    * Measure bandwidth
        + Bandwidth = N * bytes(file) / time
        + File size: 0-200 kB - varies work per request
    * All implementations exhibit similar results
        + SPED has best performance
        + Flash AMPED has extra check for memory presence
        + Zeus has anomaly (due to DMA optimization)
        + MT/MP is slower (due to context switching)
        + Apache lacks optimizations
    * Owlnet Trace
        + Trends similar to best case
        + Small trace, mostly fits in cache
        + Sometimes blocking I/O is required (SPED blocks, Flash doesn't)
    * CS Trace
        + Larger trace, mostly requires I/O
        + SPED worst -> lack of asynchronous I/O
        + MT better than MP (memory footprint, fast synchronization)
        + Flash best (smaller memory footprint -> more memory for caching,
        fewer requests -> blocking IO, no synchronization needed)
    * Optimizations were important, Apache would have performed better with
    the same optimizations applied
    * Summary of Performance Results
        + When data is in cache:
            - SPED >> Flash (unnecessary test for memory presence)
            - SPED, Flash >> MT, MP (context switching overhead)
        + When disk-bound workload:
            - Flash >> SPED (blocks because no asynchronous I/O)
            - Flash >> MT/MP (more memory efficient, less context switching)

| ![bestcase](images/best_case_results.png) |
|:--:|
| Best Case Experiment |

| ![owlnet](images/owlnet_vs_cs.png) |
|:--:|
| Owlnet vs CS Trace |

Designing Experiments

    * Relevant experiments -> Statements about a solution that others believe in
    and care about
    * Example: Web server experiment
        + Clients: Response time
        + Operators: Throughput
        + Possible Goals
            - Improved response time and throughput -> ideal
            - Improved response time -> acceptable
            - Improved response time, decreased throughput -> May be useful?
            - Maintain response time when request rate increases
            - Goals drive metrics and experiment design
        + Picking metrics
            - Standard metrics appeal to a broader audience
            - Consider operators, users
        + Picking configuration space
            - System resources: hardware (CPU, memory), software (# of threads)
            - Workload: Request rate, concurrent requests, file size, access pattern
            - Choose a subset of configuration parameters
            - Pick ranges for each variable factor
            - Pick relevant workload (include best/worst case scenarios)
            - Pick useful combinations of factors (some make same point)
        + Must compare apples to apples
        + Compare system to state-of-the-art or most common practice
            - Or ideal best/worst case scenario
    * After designing the experiments...
        + Run test cases n times
        + Compute metrics
        + Represent results
        + Draw conclusions
