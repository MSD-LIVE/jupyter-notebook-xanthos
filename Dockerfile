# FROM jupyter/minimal-notebook:2022-05-03
FROM ghcr.io/msd-live/jupyter/python-notebook:latest AS build-image

USER root

RUN mkdir -p /usr/src/xanthos
RUN cd /usr/src/xanthos && git clone https://github.com/JGCRI/xanthos.git
RUN rm -rf /usr/src/xanthos/xanthos/xanthos/data

FROM ghcr.io/msd-live/jupyter/python-notebook:latest AS main-image
USER root
COPY --from=build-image "/usr/src/xanthos" "/usr/src/xanthos"

RUN pip install "configobj>=5.0.6" "numpy<2.0" "scipy==1.14.1" "pandas<2.0" "joblib==1.4.2" "matplotlib==3.9.3"

ENV PYTHONPATH=/usr/src/xanthos/xanthos

# do this when the new single hub and efs refactor is deployed instead of /bucket and ln -s bucket
# Now create a symlinked data folder inside the msdbook package that links to /bucket folder
# RUN mkdir -p /data
# RUN ln -s data /usr/src/xanthos/xanthos/xanthos/data
# RUN chmod -R 777 /usr/src/xanthos

# RUN mkdir -p /bucket
RUN ln -s bucket /usr/src/xanthos/xanthos/xanthos/data
RUN chmod -R 777 /usr/src/xanthos

# install the msdlive plugin in order for the msdlive labs extension to discover it via entry points and 
# copy the files to users home dir instead of using the exisitng symlink to /data from users_home_dir/data
COPY msdlive_hooks /srv/jupyter/extensions/msdlive_hooks
RUN pip install /srv/jupyter/extensions/msdlive_hooks