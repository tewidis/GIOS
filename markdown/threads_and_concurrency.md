# Threads and Concurrency

A thread is the construct that allows for multiple execution contexts within a single process

    * Active entity - Executing unit of a process
    * Works simultaneously with others - Many threads generally execute at once
    * Requires coordination - Sharing of IO devices, CPUs, memory, etc.

Process vs Thread
    
    * Processes are represented by its address space
        + Contains virtual to physical address mappings (code, data, files)
        + Also represented by execution context (stack pointer, program counter)
        + All of this is contained in the Process Control Block
    * Threads are part of the same virtual address space, sharing code, data, files
        + Can operate on different portions of the input, execute different instructions
        + Require separate registers, program counter, stacks for each thread
    * Types of state:
        + Text and data (static state when process first loads)
        + Heap (dynamically created during execution)
        + Stack (grows and shrinks, LIFO queue)

| ![processlayout](images/process_vs_thread.png) |
|:--:|
| Process vs Thread |

Why are threads useful?

    * Parallelization - Can process input much faster
    * Specialization - Can give higher priority to threads that are processing more important input
        + Each thread has its own CPU cache, so the cache remains hotter
    * Efficiency - Lower memory management requirement, cheaper interprocess communication
    * Multithreaded application tends to have smaller memory footprint than multiprocess alternative
        + Threads share address space, so less duplication is required
    * Threads are still useful when # threads > # CPUs
        + if( t_idle > 2 * t_ctx_switch )
        + t_ctx_switch_thread < t_ctx_switch_process
        + Can hide latency associated with IO operations
    * Benefits:
        + Multithreading OS kernel allows OS to support multiple execution contexts
        + Particularly useful when there are multiple CPUs
        + Can run daemons or device drivers

What do we need to support threads?

    * Data structure to identify threads, keep track of resource usage
    * Mechanisms to create and manage threads
    * Mechanisms to safely coordinate among threads
    * Thread type (thread data structure)
        + Thread ID
        + PC
        + SP
        + Registers
        + Stack
        + Other attributes (priority)
    * Fork (process, arguments)
        + Create a thread (not the same as a UNIX fork system call)
        + t1 = fork(proc, args)
    * Join(thread) - Terminate a thread
        + child.result = join(t1)

Mutual Exclusion
    
    * Lock that should be used when accessing any data shared among threads
    * Elements:
        + locked?
        + owner
        + blocked_threads
    * Critical section - Portion of code protected by the mutex

Condition Variables

    * Used in conjunction with mutexes to control the behavior of concurrent threads
    * Useful in producer/consumer example
        + Consumer can "wait" on a condition, producers can "signal" the consumer when true

| ![processlayout](images/producer_consumer.png) |
|:--:|
| Producer/Consumer Example |

Condition Variables API

    * Condition type
    * wait(mutex, condition)
        + Mutex is automatically released and reacquired on wait
    * signal(condition)
        + Notify only one thread waiting on condition
    * broadcast(condition)
        + Notify all waiting threads

| ![processlayout](images/reader_writer.png) |
|:--:|
| Reader/Writer Example |

Critical Section Structure

    * lock(mutex)
        + while(!predicate_indicating_access_ok)
            - wait(mutex, cond_var)
        + update state => update predicate
        + signal and/or broadcast (cond_var_with_correct_waiting_threads)
    * unlock(mutex)

Common Pitfalls

    * Keep track of mutex/condition variables are associated with which resource
        + mutex_tpye m1; // mutex for file1
    * Check that you are always (and correctly) using lock and unlock
        + Some compilers can generate warnings and errors
    * Use a single mutex to access a single resource
    * Check that you are signaling the correct condition
    * Check that you are not using signal when broadcast is needed
        + Only one thread will proceed on signal, others will wait (possibly indefinitely)
    * Thread execution order is not guaranteed by the order they are signalled

Spurious Wake Ups

    * Definition: Threads are signalled while the mutex they require is still held elsewhere
    * Still correct, but hurts performance
    * Occurs when a broadcast/signal call is made while the mutex is still held

Deadlocks
    
    * Definition: Two or more competing threads waiting on each other to complete, but neither do
    * Can occur when two threads lock the same mutexes in different orders
    * Maintaining a lock order can prevent this
        + Acquiring mutex B implies mutex A is already acquired
    * A cycle in the wait graph is necessary and sufficient for a deadlock to occur
        + Edges from thread waiting on a response to thread owning a resource
    * What can we do about it?
        + Deadlock prevention - Lock order, but can be expensive
        + Deadlock detection and recovery - Rollback, generally less expensive
        + Apply the ostrich algorithm - Do nothing, reboot if deadlock happens

Kernel-Level vs User-Level Threads

    * User-level threads must be associated with a kernel-level thread
        + Scheduling is handled by the scheduler in the kernel
    * One-to-one Model - One kernel thread per user thread
        + Pros:
            - OS sees/understands threads, synchronization, blocking
        + Cons
            - Must go to OS for all operations (expensive)
            - OS may have limits on policies and number of threads
            - Portability
    * Many-to-one Model - Multiple user-level threads mapped to a single kernel-level thread
        + Pros:
            - Totally portable, doesn't depend on OS limits and policies
        + Cons:
            - OS has no insight into application needs
            - OS may block entire process if one user-level thread blocks on IO
    * Many-to-many Model - Some user-level threads mapped one-to-one, others one-to-many
        + Pros:
            - Can be the best of both worlds
            - Can have bound (one-to-one) and unbound (many-to-one) mappings
        + Cons:
            - Requires coordination between user- and kernel-level thread managers
    * Scope of Multithreading
        + System scope - System-wide thread management by OS-level thread managers (CPU scheduler)
        + Process scope - User-level library manages threads within a single process

Multithreading Patterns

    * Boss-Workers
    * Pipeline
    * Layered

Boss/Workers Pattern

    * Boss assigns work to workers
    * Workers perform entire task assigned to them
    * Throughput of system is limited by boss thread -> must keep boss efficient
    * Throughput = 1 / boss_time_per_order
    * Boss can assign work by...
        + Directly signalling specific worker
            - Pros - Workers don't need to synchronize
            - Cons - Boss must track what each worker is doing, so throughput is lower
        + Placing work in producer/consumer queue
            - Pros - Boss doesn't need to know details about workers
            - Cons - Queue synchronization
    * Producer/consumer queue gives better throughput
    * How many workers is enough?
         + On demand - Add as needed
         + Pool of workers - Number of threads is generally dynamically allocated
    * Pros - Simplicity
    * Cons - Thread pool management, locality
    * Instead of creating all workers equal, we can specialize workers for certain tasks
        + Pros - Better locality and quality of service management
        + Cons - Load balancing becomes more difficult
    * Throughput = time_to_complete * ceiling( num_jobs / num_workers )

Pipeline Pattern
    
    * Threads assigned to one subtask in the system
    * Entire task is executed as a pipeline of threads
    * Multiple tasks are executed concurrently in the system at different pipeline stages
    * Throughput - Only as fast as the slowest stage of the pipeline
        + Can assign more threads from a pool to the slowest stage
    * Shared buffer used for communication between stages 
    * Pros - Specialization and locality
    * Cons - Balancing and synchronization overheads
    * Throughput = time_to_complete_one + ( ( num_jobs - 1 ) * time_to_complete_last_stage )

Layered Pattern

    * Each layer is assigned a group of related tasks
    * End-to-end task must pass up and down through all layers
    * Pros - Specialization and locality, but less fine-grained than pipeline
    * Cons - Not suitable for all applications, synchronization between layers
