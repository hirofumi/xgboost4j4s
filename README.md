# xgboost4j4s

[![Build Status](https://travis-ci.org/hirofumi/xgboost4j4s.svg?branch=master)](https://travis-ci.org/hirofumi/xgboost4j4s)
[![Scaladex](https://maven-badges.herokuapp.com/maven-central/com.github.hirofumi/xgboost4j_2.11/badge.svg)](https://index.scala-lang.org/hirofumi/xgboost4j4s/xgboost4j)

[XGBoost4J](https://xgboost.readthedocs.io/en/latest/jvm/index.html) with cross-version suffix

## Usage

```sbt
// available for Scala 2.11 and 2.12
libraryDependencies += "com.github.hirofumi" %% "xgboost4j" % "0.7.0-p2" 

// available for Scala 2.11
libraryDependencies += "com.github.hirofumi" %% "xgboost4j-flink" % "0.7.0-p2"
libraryDependencies += "com.github.hirofumi" %% "xgboost4j-spark" % "0.7.0-p2"
```

### Note

You should use the above libraries with `LC_NUMERIC=C` (which is not overridden by `LC_ALL`) on macOS.
Otherwise multi-threading may cause a segmentation fault.

## Development

### Prerequisites

* macOS
* Docker for Mac
* Ninja
* `g++-7` (installed by Homebrew, i.e. `brew install gcc`)

### How to Build and Test

```
$ make test
```

### How to Release

```
$ make release
```

## Prior Work

* https://github.com/dmlc/xgboost/pull/2767
* https://github.com/criteo-forks/xgboost-jars
* https://github.com/nevillelyh/xgboost-dist
* https://github.com/myui/build-xgboost-jvm
