import PgpKeys._
import sbtrelease.ReleasePlugin.autoImport.ReleaseTransformations._
import scala.sys.process._
import xerial.sbt.Sonatype._

lazy val `xgboost-jvm` =
  project
    .in(file("."))
    .aggregate(
      xgboost4j,
      // `xgboost4j-example`,
      `xgboost4j-flink`,
      `xgboost4j-spark`
    )
    .settings(settings ++ notToPublish)
    .settings(
      makeClean := "make clean".!,
      makeDoc   := "make doc".!,
      makeTest  := "make test".!
    )
    .settings(
      releaseCrossBuild :=
        true,
      releaseProcess := Seq[ReleaseStep](
        checkSnapshotDependencies,
        inquireVersions,
        runClean,
        runTest,
        setReleaseVersion,
        commitReleaseVersion,
        tagRelease,
        releaseStepCommand("publishSigned"),
        setNextVersion,
        commitNextVersion,
        releaseStepCommand("sonatypeReleaseAll"),
        pushChanges
      )
    )

lazy val xgboost4j =
  project
    .in(file("xgboost/jvm-packages/xgboost4j"))
    .settings(settings ++ toPublish)
    .settings(
      crossScalaVersions += "2.12.4"
    )
    .settings(
      libraryDependencies ++= Seq(
        "com.typesafe.akka" %% "akka-actor"   % akkaVersion.value,
        "com.typesafe.akka" %% "akka-testkit" % akkaVersion.value % Test,
        "junit"             %  "junit"        % "4.11"            % Test
      )
    )

/* pom.xml of flink-ml 0.10.2 seems to cause a "Conflicting cross-version suffixes" error
lazy val `xgboost4j-example` =
  project
    .in(file("xgboost/jvm-packages/xgboost4j-example"))
    .dependsOn(`xgboost4j-flink`, `xgboost4j-spark`)
    .settings(settings ++ notToPublish)
    .settings(
      libraryDependencies ++= Seq(
        "org.apache.spark" %% "spark-mllib" % "2.1.0" % Provided
      )
    )
*/

lazy val `xgboost4j-flink` =
  project
    .in(file("xgboost/jvm-packages/xgboost4j-flink"))
    .dependsOn(xgboost4j % "compile;test->test")
    .settings(settings ++ toPublish)
    .settings(
      libraryDependencies ++= Seq(
        "org.apache.commons" %  "commons-lang3" % "3.4",
        "org.apache.flink"   %% "flink-clients" % "0.10.2",
        "org.apache.flink"   %% "flink-ml"      % "0.10.2",
        "org.apache.flink"   %% "flink-scala"   % "0.10.2"
      )
    )

lazy val `xgboost4j-spark` =
  project
    .in(file("xgboost/jvm-packages/xgboost4j-spark"))
    .dependsOn(xgboost4j % "compile;test->test")
    .settings(settings ++ toPublish)
    .settings(
      parallelExecution in Test := false
    )
    .settings(
      libraryDependencies ++= Seq(
        "org.apache.spark" %% "spark-mllib" % "2.1.0" % Provided
      )
    )

lazy val settings =
  Seq(
    akkaVersion                      := (if (isScala211.value) "2.3.11" else "2.4.20"),
    crossScalaVersions               := Seq("2.11.8"),
    isScala211                       := (scalaBinaryVersion.value == "2.11"),
    javacOptions                    ++= Seq("-source", "1.7", "-target", "1.7"),
    licenses                         := Seq("Apache-2.0" -> url("https://www.apache.org/licenses/LICENSE-2.0.txt")),
    organization                     := "com.github.hirofumi",
    scalaVersion                     := "2.11.8",
    scalacOptions                   ++= Seq("-deprecation", "-encoding", "UTF-8", "-feature"),
    scalacOptions                    += (if (isScala211.value) "-target:jvm-1.7" else "-target:jvm-1.8"),
    scalacOptions in (Compile, doc) ++= (if (isScala211.value) Nil else Seq("-no-java-comments")), // https://github.com/scala/scala-dev/issues/249#issuecomment-255863118
    testOptions                      += Tests.Argument(TestFrameworks.ScalaTest, "-oDF")
  ) ++ Seq(
    baseDirectory in (Test, test) := (baseDirectory in ThisBuild).value / "xgboost" / "jvm-packages",
    fork          in (Test, test) := true
  ) ++ Seq(
    libraryDependencies ++= Seq(
      "com.esotericsoftware.kryo" %  "kryo"            % "2.21",
      "commons-logging"           %  "commons-logging" % "1.2",
      "org.scalatest"             %% "scalatest"       % "3.0.0" % Test
    ),
    sonatypeProjectHosting := Some(
      GithubHosting("hirofumi", "xgboost4j4s", "hirofummy@gmail.com")
    )
  )

lazy val notToPublish =
  Seq(
    publish         := {},
    publishArtifact := false,
    publishLocal    := {},
    publishSigned   := {}
  )

lazy val toPublish =
  Seq(
    publishMavenStyle          := true,
    publishSignedConfiguration := publishSignedConfiguration.value.withOverwrite(isSnapshot.value),
    publishTo                  := sonatypePublishTo.value
  )

lazy val akkaVersion = settingKey[String]("akka version")
lazy val isScala211  = settingKey[Boolean]("whether or not scalaBinaryVersion is 2.11")

lazy val makeClean = taskKey[Int]("make clean")
lazy val makeDoc   = taskKey[Int]("make doc")
lazy val makeJni   = taskKey[Int]("make jni")
lazy val makeTest  = taskKey[Int]("make test")
