# PThreads

PThreads == POSIX Threads (Portable Operating System Interface)

    * POSIX specifies syntax and semantics of the operations

PThreads Creation
    
    * pthread_t aThread; // type of thread
    * int pthread_create(pthread_t*, const pthread_attr_t*, void* (*start_routine)(void*), void* arg);
    * int pthread_join(pthread_t thread, void** status);

Pthread Attributes

    * Stack Size
    * Inheritance
    * Joinable
    * Scheduling Policy
    * Priority
    * System/Process Scope
    * Functions
        + int pthread_attr_init(pthread_attr_t* attr);
        + int pthread_attr_destroy(pthread_attr_t* attr);
        + int pthread_attr_set(attribute);
        + int pthread_attr_get(attribute);
    * Joinable Threads - Parent thread won't terminate until children complete
    * Detachable Threads - Child threads can't be rejoined, continue if parent exits

Compiling PThreads
    
    * #include <pthread.h>
    * Compile with -lpthread
    * Check return values of common functions

PThread Example 1

| ![example1](images/pthread_example1.png) |
|:--:|
| PThread Example 1 |

This program prints Hello world four times.


PThread Example 2

| ![example2](images/pthread_example2.png) |
|:--:|
| PThread Example 2 |

The output of this program is indeterminate.
Passing the address of i means that the value could be updated before the thread prints.
This is a race condition between the reader and writer threads.
This is fixed in the following example.

| ![example2_fixed](images/pthread_example2_fixed.png) |
|:--:|
| PThread Example 2 Fixed |

The output of this program is 0, 1, 2, 3 in an indeterminate order.

PThread Mutexes

    * Method to solve mutual exclusion problems among concurrent threads
    * pthread_mutex_t aMutex; // mutex type
    * int pthread_mutex_lock(pthread_mutex_t* mutex); // explicit lock
    * int pthread_mutex_unlock(pthread_mutex_t* mutex); // explicit unlock
    * int pthread_mutex_init(pthread_mutex_t* mutex, const pthread_mutex_attr_t* attr);
    * int pthread_mutex_trylock(pthread_mutex_t* mutex); // returns if mutex is locked
    * int pthread_mutex_destroy(pthread_mutex_t* mutex);

Mutex Safety Tips

    * Shared data should always be accessed through a single mutex
    * Mutex scope must be visible to all
    * Globally order locks (lock mutexes in the same order for all threads)
    * Always unlock the correct mutex

Condition Variables

    * pthread_cond_t aCond; // type of condition variable
    * int pthread_cond_wait(pthread_cond_t* cond, pthread_mutex_t* mutex);
    * int pthread_cond_signal(pthread_cond_t* cond);
    * int pthread_cond_broadcast(pthread_cond_t* cond);
    * int pthread_cond_init(pthread_cond_t* cond, const pthread_condattr_t* attr);
    * int pthread_cond_destroy(pthread_cond_t* cond);

Condition Variables Safety Tips

    * Don't forget to notify waiting threads
        + Predicate change -> signal/broadcast correct condition variable
    * When in doubt, use broadcast (incurs performance penalty)
    * You don't need a mutex to signal/broadcast (wait until after mutex is unlocked)

Producer/Consumer Example Using PThreads

| ![producer_consumer1](images/pthread_producer_consumer1.png) |
|:--:|
| PThread Producer/Consumer Global |

| ![producer_consumer2](images/pthread_producer_consumer2.png) |
|:--:|
| PThread Producer/Consumer Main |

| ![producer_consumer3](images/pthread_producer_consumer3.png) |
|:--:|
| PThread Producer/Consumer Producer |

| ![producer_consumer4](images/pthread_producer_consumer4.png) |
|:--:|
| PThread Producer/Consumer Consumer |
