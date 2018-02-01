GCC_HOME=/usr/local/opt/gcc
GCC_VERSION=7
CC="$(GCC_HOME)/bin/gcc-$(GCC_VERSION)"
CXX="$(GCC_HOME)/bin/g++-$(GCC_VERSION)"
CFLAGS="-fvisibility=hidden -static-libgcc -I$(GCC_HOME)/include"
CXXFLAGS="-fvisibility=hidden -fvisibility-inlines-hidden -static-libgcc -static-libstdc++"
LIBGOMP_A="$$(cd $$(dirname $$($(CXX) -print-file-name=libgomp.a)); pwd)/libgomp.a"
RESOURCES_METAINF=xgboost/jvm-packages/xgboost4j/src/main/resources/META-INF
RESOURCES_LIB=xgboost/jvm-packages/xgboost4j/src/main/resources/lib
LIBXGBOOST4J_DYLIB=$(RESOURCES_LIB)/libxgboost4j.dylib
LIBXGBOOST4J_SO=$(RESOURCES_LIB)/libxgboost4j.so
RUN_ON_DOCKER=(docker image inspect xgboost4j4s-jni > /dev/null || docker build . -t xgboost4j4s-jni) && docker run --rm -v "`pwd`/$(RESOURCES_METAINF):/root/$(RESOURCES_METAINF)" -v "`pwd`/$(RESOURCES_LIB):/root/$(RESOURCES_LIB)" -i xgboost4j4s-jni

IVY2_CACHE=$$(pwd)/docker-cache/.ivy2/cache
SBT_CACHE=$$(pwd)/docker-cache/.sbt

IVY2_CACHE_VOLUME=$$(if [ -n "$(IVY2_CACHE)" ]; then echo -v "$(IVY2_CACHE):/root/.ivy2/cache"; else echo -n ''; fi)
SBT_CACHE_VOLUME=$$(if [ -n "$(SBT_CACHE)" ]; then echo -v "$(SBT_CACHE):/root/.sbt"; else echo -n ''; fi)

.PHONY: \
  test test-mac test-linux test-fedora test-ubuntu \
  release \
  publish-local publish-snapshot \
  inspect-dylib inspect-so \
  clean clean-dylib clean-so \
  doc \
  jni jni-dylib jni-so

test: test-mac test-linux

test-mac: jni-dylib
	LC_NUMERIC=C sbt test

test-linux: test-fedora test-ubuntu

test-fedora: jni-so
	docker build . -f Dockerfile.test-fedora -t xgboost4j4s-test-fedora
	docker run --rm $(IVY2_CACHE_VOLUME) $(SBT_CACHE_VOLUME) -i xgboost4j4s-test-fedora

test-ubuntu: jni-so
	docker build . -f Dockerfile.test-ubuntu -t xgboost4j4s-test-ubuntu
	docker run --rm $(IVY2_CACHE_VOLUME) $(SBT_CACHE_VOLUME) -i xgboost4j4s-test-ubuntu

release: clean doc jni
	sbt release

publish-local: doc jni
	sbt +publishLocal

publish-snapshot: doc jni
	sbt +publishSigned

inspect: inspect-dylib inspect-so

inspect-dylib: jni-dylib
	ls -lat "$(LIBXGBOOST4J_DYLIB)"
	otool -L "$(LIBXGBOOST4J_DYLIB)"

inspect-so: jni-so
	$(RUN_ON_DOCKER) ls -lat "$(LIBXGBOOST4J_SO)"
	$(RUN_ON_DOCKER) ldd "$(LIBXGBOOST4J_SO)"
	$(RUN_ON_DOCKER) strings "$(LIBXGBOOST4J_SO)" | grep ^GLIBC

clean: clean-doc clean-dylib clean-so
	rm -rf docker-cache; git checkout HEAD -- docker-cache
	-docker rmi xgboost4j4s-jni
	-docker rmi xgboost4j4s-test-fedora
	-docker rmi xgboost4j4s-test-ubuntu

clean-doc:
	rm -rf "$(RESOURCES_METAINF)"

clean-dylib:
	sbt +clean
	-rm "$(LIBXGBOOST4J_DYLIB)"
	rm -rf xgboost/build

clean-so:
	-rm "$(RESOURCES_LIB)/libgomp.so"
	-rm "$(LIBXGBOOST4J_SO)"

doc: $(RESOURCES_METAINF)/xgboost/LICENSE $(RESOURCES_METAINF)/g++/copyright

jni: jni-dylib jni-so

jni-dylib: $(LIBXGBOOST4J_DYLIB)

jni-so: $(LIBXGBOOST4J_SO)

$(LIBXGBOOST4J_DYLIB):
	cd xgboost/jvm-packages \
	  && cat create_jni.py \
	     | sed -e 's!CONFIG\["USE_OPENMP"\] = "OFF"!CONFIG["USE_OPENMP"] = "ON"!' \
	     | sed -e 's!join(args)!join(args + ["-DOpenMP_'$(LIBGOMP_A)'_LIBRARY='$(LIBGOMP_A)'"])!' \
	     > create_jni.py~ \
	  && CC=$(CC) CXX=$(CXX) LDFLAGS=$(LDFLAGS) CXXFLAGS=$(CXXFLAGS) \
	     CMAKE_POLICY_DEFAULT_CMP0066=NEW \
	     python create_jni.py~

$(LIBXGBOOST4J_SO): $(RESOURCES_LIB)/libgomp.so
	$(RUN_ON_DOCKER) bash -c "cd xgboost/jvm-packages && python create_jni.py"

$(RESOURCES_METAINF)/g++/copyright:
	mkdir -p "$(RESOURCES_METAINF)/g++"
	$(RUN_ON_DOCKER) cp -p /usr/share/doc/g++-6/copyright $(RESOURCES_METAINF)/g++

$(RESOURCES_METAINF)/xgboost/LICENSE:
	mkdir -p "$(RESOURCES_METAINF)/xgboost"
	cp -p xgboost/LICENSE "$(RESOURCES_METAINF)/xgboost"

$(RESOURCES_LIB)/libgomp.so:
	$(RUN_ON_DOCKER) bash -c 'cp -Lpv "$$(gcc --print-file-name libgomp.so)" "$(RESOURCES_LIB)"'
