## **WebSpectrum Docker**
This is a convenience repo to showcase the gr-webspectrum module connecting a GNURadio flowgraph to a web-based waterfall/spectrum display. When built, a Docker image is produced that contains GNURadio, the gr-webspectrum module, a Redis backend and Uvicorn ASGI webserver.
This repo links to gr-webspectrum as a submodule (https://github.com/muaddib1984/gr-webspectrum). More details can be found there.

## **Quick Start**
### Pull the image from DockerHub

```docker pull muaddib1984/alpine_gnuradio_webspectrum:slimwebspectrum_deploy```
### **Run the Container**

```docker run -dt --name slimwebspectrum_deploy -p 8000:8000 muaddib1984/alpine_gnuradio_webspectrum:slimwebspectrum_deploy```

### **Connect to the container**

Open a web browser to http://127.0.0.1:8000
you should see this:
![](/img/mainpage.png)

clicking on the 'start viewing spectrum' button will show this

![](/img/spectralpage.png)

### **Stop the Container**

```docker stop slimwebspectrum_deploy```

## **Building Images**
There are 2 Dockerfile's that both use Multi-Stage Builds. Each produces the same functionality to the user, however each provides different flexibility for development. 

NOTE: You do not have to build each stage independently. The steps needed to build the individual stages are shown for verbosity and development.

```Dockerfile``` uses Alpine APK packages of GNURadio 3.10.7 and produces a 'deploy' image that is ~500MB. This image can also use OOT modules, provided they are built in the 'build' stage and necessary libs are copied over to the 'deploy' stage.

```Dockerfile.slimwebspectrum``` build stage compiles a minimal version of GNURadio that includes only in-tree modules needed by  ```gr-webspectrum```. The ```Dockerfile.slimwebspectrum``` also uses an Embedded Python Block version of the ```gr-webspectrum``` ```Broadcaster``` block so that only in-tree modules are required for runtime. This produces a 'deploy' image that is ~250MB (about half the size of the ```Dockerfile```'s webspectrum 'deploy' image).

### **Dockerfile(s)**
Multi-Stage Build basic Contents:

#### **"build" stage**
* Python 3.11 Alpine Linux base
* [gnuradio-dev v3.10.7 APK](https://pkgs.alpinelinux.org/package/v3.19/community/x86_64/gnuradio-dev)
* gr-webspectrum built from source
* redis
* uvicorn


to build, run:

```docker build -t webspectrum_build --target build -f Dockerfile .```

to run the container, run:

```docker run --name webspectrum_build -p 8000:8000 webspectrum_build ```

Build Image Size: ~1.6GB


#### **"deploy" stage**
* Python3.11 Alpine Linux base
* [gnuradio v3.10.7 APK](https://pkgs.alpinelinux.org/package/v3.19/community/x86_64/gnuradio-dev)
* redis
* uvicorn
* gr-webspectrum built from source

to build, run:

```docker build -t webspectrum_deploy --target deploy -f Dockerfile .```

to run container, run:

```docker run --name webspectrum_deploy -p 8000:8000 webspectrum_deploy```

"Deploy" Image size: ~500MB

***

### **Dockerfile.slimwebspectrum**
Multi-Stage Build basic Contents:

#### **"build" stage**
* Python 3.11 Alpine Linux base
* GNURadio 3.10.7 from source (with only the needed in-tree modules for webspectrum)
* gr-webspectrum built from source
* redis
* uvicorn

to build, run:

```docker build -t slimwebspectrum_build --target build -f Dockerfile.slimwebspectrum .```

to run container, run:

```docker run --name slimwebspectrum_build -p 8000:8000 slimwebspectrum_build ```

Build Image size: ~4.2GB

#### **"deploy" stage**
* Python3.11 Alpine Linux base
* Copied GNURadio 3.10.7 libs from 'build' stage
* redis
* uvicorn
* gr-webspectrum embedded python ```broadcaster``` block

to build, run:

```docker build -t slimwebspectrum_deploy --target deploy -f Dockerfile.slimwebspectrum .```

to run container, run:

```docker run --name slimwebspectrum_deploy -p 8000:8000 slimwebspectrum_deploy```

Deploy Image size: ~250MB

### USAGE
Once any of the containers are running:
navigate to ```0.0.0.0:8000``` in a local web browser to see the intro page and keyboard shortcuts

click "start viewing spectrum" to see the spectral display
-or-
navigate to ```0.0.0.0:8000/spectral``` to see the spectrum immediately
