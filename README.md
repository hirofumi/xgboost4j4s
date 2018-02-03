# xgboost4j4s

[![Build Status](https://travis-ci.org/hirofumi/xgboost4j4s.svg?branch=master)](https://travis-ci.org/hirofumi/xgboost4j4s)
[![Scaladex](https://maven-badges.herokuapp.com/maven-central/com.github.hirofumi/xgboost4j_2.11/badge.svg)](https://index.scala-lang.org/hirofumi/xgboost4j4s/xgboost4j)

XGBoost4J with cross-version suffix

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
