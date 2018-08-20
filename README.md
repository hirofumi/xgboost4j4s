# xgboost4j4s

[![Build Status](https://travis-ci.org/hirofumi/xgboost4j4s.svg?branch=master)](https://travis-ci.org/hirofumi/xgboost4j4s)
[![Maven Central](https://maven-badges.herokuapp.com/maven-central/com.github.hirofumi/xgboost4j_2.11/badge.svg)](https://search.maven.org/search?q=g:com.github.hirofumi%20xgboost4j)

[XGBoost4J](https://xgboost.readthedocs.io/en/latest/jvm/index.html) with cross-version suffix

## Usage

```sbt
// available for Scala 2.11 and 2.12
libraryDependencies += "com.github.hirofumi" %% "xgboost4j" % "0.80-p1"

// available for Scala 2.11
libraryDependencies += "com.github.hirofumi" %% "xgboost4j-flink" % "0.80-p1"
libraryDependencies += "com.github.hirofumi" %% "xgboost4j-spark" % "0.80-p1"
```

### Note

* You should use the above libraries with `LC_NUMERIC=C` (which is not overridden by `LC_ALL`) on macOS.
  Otherwise multi-threading may cause a segmentation fault.
* This library contains some GCC runtime libraries and I think GCC Runtime Library Exception can be applied.
  But I am not a lawyer.

## Development

### Prerequisites

* macOS
* Docker for Mac
* Ninja
* `g++-7` (installed by Homebrew, i.e. `brew install gcc@7`)

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
