---
title: Java Build Tool Cheatsheet
---
|                 | |    [ant](http://ant.apache.org/)      | |    [maven](http://maven.apache.org/)      | |    [gradle](https://gradle.org/)     | |     [sbt](http://www.scala-sbt.org/)       | |     [lein](http://leiningen.org/)      |
|---------------  |-|:---------:  |-|:-----------:  |-|:------------: |-|:-----------:  |-|:------------: |
| **Build config:**   || `build.xml`   ||   `pom.xml`     || `build.gradle`  || `build.sbt`     || `project.clj`   |
| **Build a JAR:**    || `ant jar`     || `mvn package`   || `gradle build`  || `sbt package`   || `lein uberjar`  |
| **List tasks:**     || `ant -p`      || [read a book](http://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle%5FReference)   || `gradle tasks`  || `sbt tasks`     || `lein help`     |
