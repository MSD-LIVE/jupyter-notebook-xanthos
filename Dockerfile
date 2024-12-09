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

# Now create a symlinked data folder inside the msdbook package that links to /bucket folder
RUN mkdir -p /bucket
RUN ln -s bucket /usr/src/xanthos/xanthos/xanthos/data
RUN chmod -R 777 /usr/src/xanthos
