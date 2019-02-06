Modern Java Runtimes Basic Performance
==============================
This project contains several applications written using a collection of modern Java-based runtimes. It is intended to use this for rough
comparisons of app disk footprint, memory, and throughput for basic "Hello World"-type applications using the default settings for each of the runtimes.

This is not a rigorous test of all application performance characteristics, and is not intended to be the "final say" in runtime performance - careful tuning based on expected workloads must be done.

Scenarios Included
----------------------
* [Red Hat JBoss EAP](https://developers.redhat.com/products/eap/overview/) 7.2 using a basic [Java EE 8](https://www.oracle.com/technetwork/java/javaee/overview/index.html) REST application
* [Red Hat JBoss EAP](https://developers.redhat.com/products/eap/overview/) 7.2 using a basic [Spring](https://spring.io/) REST application
* [Red Hat JBoss Web Server](https://developers.redhat.com/products/webserver/overview/) 5.0 (based on [Apache Tomcat](https://tomcat.apache.org/index.html) 9.x) using a basic Spring REST application
* [Spring Boot](https://spring.io/projects/spring-boot) 2.x REST application deployed as a Fat JAR
* [Eclipse Vert.x](https://vertx.io/) 3.6 REST application deployed as a Fat JAR
* [Thorntail](https://thorntail.io/) 2.3 REST application deployed as a Fat JAR

Prerequisites
----------------------
To run these commands you need:

- A Bash or Bourne Shell console (e.g. on Linux or Mac)
- A Java development environment (JDK 8 or greater, such as [Red Hat OpenJDK](https://developers.redhat.com/products/openjdk/overview/)) with commands like `java`, `javac`, `jconsole` on your `$PATH`
- Typical web development utilities [`curl`](https://curl.haxx.se/), `unzip` on your `$PATH`
- [Maven](https://maven.apache.org) 3.5.3+
- [Apache Bench](https://httpd.apache.org/docs/2.4/programs/ab.html) 2.3+
- To test JBoss products, you'll need to download and copy production zip files to the `installs/` directory. See the [`installs/README.md`](installs/README.md) for more detail on which zip files you'll need.

Running the tests
------------------
Clone this repo using [`git`](https://git-scm.com/) or some other [Git](https://git-scm.com/)-compatible environment, and then run the following command to output the available tests:

```sh
./run.sh
Valid commands:
run.sh spring-boot      # [Runs as a Spring Boot Fat JAR]
run.sh vertx            # [Runs as a Eclipse Vert.x Fat JAR]
run.sh jws              # [Runs JBoss Web Server]
run.sh thorntail        # [Runs Thorntail]
run.sh jboss-eap-spring # [Runs JBoss EAP with Spring app]
run.sh jboss-eap-javaee # [Runs JBoss EAP with Java EE app]
run.sh kill-all         # [Stops all servers]
```

Each test will:

1. Install any necessary products
1. Start the server or Fat JAR
1. Open `jconsole` (you'll need to accept the _Insecure Connection_ Dialog box)
1. Run a warm-up test
1. Run the actual performance using Apache Bench with the specified iterations and concurrency specified at the top of `run.sh`
1. Wait for the test to finish
1. Stop the server or Fat JAR

After the test completes, you can find throughput information in `performance.txt` and log files from various runtimes in `*.log`. You can also watch the memory and other VM usage patterns in JConsole.

