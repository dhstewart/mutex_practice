# Practing Ruby Threads/Mutex/Queue

I started working on this because I wanted to learn more about how Ruby Threads,
 Mutexes, and Queues work.


### What this is

This is a simple exercise to illustrate the problem that happens when multiple
threads in Ruby compete for the same resource when that resource needs to be
treated atomically.

We show two problems that can arise in web development that we are able to solve
using some simple techniques available in Ruby.

### What this is not

This is not attempt to solve all the problems facing the pretend developers of the
example Roda app we are using. If we wanted to do that there are a lot of much
simpler ways of dealing with this that immediately come to mind.

### Context

We want to illustrate the problem of non atomic transactions with a small,
contrived example.

In this exercise there will always be a rack app (a Roda app) that you mount up
that can respond to some http requests that I've wrapped up into some Ruby files
that shell out to Apache Benchmark.

The endpoint handling our POST request has a simple responsibilty: create a $1
donation for the charity in our dataase.

Our contrived constraint is that we can't yet actually create donations, so we
have to update the actual charity object in our database to increment its
`donated_dollars` column.

### Before you start

In the excercise several versions of the Roda app exist. Each version is run
by `cd`ing into the proper directory and running `rackup` in your terminal
session. Type `ctrl-c` to stop the app.

Make sure port 9292 is available on localhost since the Roda app binds to that
port.

- `git clone git@github.com:dhstewart/mutex_practice.git`
- cd mutex_practice
- make sure you're in the project root dir
- `bundle install`

One last caveat: I've only tested this on Mac OS X version 10.14.2

So if you plan on actually running it on Linux/Windows/etc your MMV

You're all set!

### Scenario 1 problem: our api is blasted by concurrent requests

  How to illustrate the problem:

  - make sure you are in mutex_practice two terminal sessions
  - in the first terminal:
    `rackup`
  - in the second terminal, send 1000 requests:
    `ruby requests/post_concurrent_donations.rb`

  This version of our app runs into a problem around the resource, in this case
  the charity, not being handled in an atomic way.

  In this simple application, n POST requests should increment
  the donated_dollars amount from 0 to n.

  Because the resources are not being acted on atomically, when
  we do our GET request to see the total value, this expectation is not
  always met.

  Once you run the commands above you can run:
  `ruby requests/get_total_donations.rb`

  This will print the total out in the session running the roda app.

  You can verify that the total recorded amount is not reflective of the number
  of POSTs that we made.

### Scenario 1 solution

  - in the first terminal, close the rack app with:
    `ctrl-c`
  - in the first terminal, cd into the dir with a mutexed version of the roda app
    `cd mutexed_version`
  - in the first terminal: `rackup`
    (bc we use sqlite3, the in memory database just blows away so
    we don't have to worry about old data)
  - in the second terminal run the same as before:
    `ruby requests/post_concurrent_donations.rb`

  - get the total donations to print `ruby requests/get_total_donations.rb`

  This time, you will consistently see that the total donated was exactly what
  we expect at the end.

  Take a look into the mutexed_version/config.ru file and you will see that we
  are using a Mutex to protect the critical region of the code. This is the
  area of the code that we only want 1 thread acting on at a time to avoid
  threads dealing with stale data.

### Scenario 2 problem: A slow, inline process is causing clients to time out

  In this scenario we want to:

  - use our same concurrent posts file
  - have our api sleep long enough to cause a timeout issue on the client

  This way we simulate a client who has a need for fast responses and
  and api that currently cannot handle the requirements.

  - in the first terminal, close the rack app with:
    `ctrl-c`
  - in the first terminal, cd into the dir with a slow version of the roda app
    `cd ../long_process`
  - in the first terminal: `rackup`
    (bc we use sqlite3, the in memory database just blows away so
    we don't have to worry about old data)
  - in the second terminal run the same as before:
    `ruby requests/post_concurrent_donations.rb`

  after we run our requests we expect to see Apache Benchmark complain:

  `apr_pollset_poll: The timeout specified has expired (70007)`

### Scenario 2 solution: Queuing up async processes

  Standard solutions:
  There's a lot ways to solve this issue that are already wrapped up nicely in
  gems. I think that doing an exercise like this might help strengthen thinking
  and understanding around those strategies.

  Also, we want to stay away from solutions that violate our constraint which is
  that we must update the one charity database record.

  - in the first terminal, close the rack app with:
    `ctrl-c`
  - cd into the dir with a queued/async functionality
    `cd ../queued`
  - in the first terminal: `rackup`
    (bc we use sqlite3, the in memory database just blows away so
    we don't have to worry about old data)
  - in the second terminal run the same as before:
    `ruby requests/post_concurrent_donations.rb`

  This time, you will see that the requests are all able to be made with a
  proper response. The jobs will slowly be worked off on the backend by the
  atomic worker. You'll probably want to just `ctrl-c` after you see a few of
  them process since 1000 jobs that take 5 seconds each to process and must be
  processed one at a time is going to take a while.

  If you look at the files in the queued dir, you'll see that the Roda endpoint
  is now offloading the long running process to a worker. This way, we can get
  a response back to the client to let them know that the request is being
  processed.

  The worker still works atomically because we have put a mutex around access
  to working jobs off of this queue, which is why we've called it AtomicWorker.


### Next Steps

I'd like to clean this up a bit and make it a little more friendly to run and
see the results.
