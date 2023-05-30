# This image already includes Python 3.9, JupyterLab and base data science tools + CUDA 11.8 + CuDNN 8.6
FROM quay.io/opendatahub-contrib/workbench-images:cuda-jupyter-datascience-c9s-py39_2023b_latest

LABEL name="odh-notebook-cuda-jupyter-tensorflow-ubi9-python-3.9" \
    summary="Jupyter CUDA tensorflow notebook image for ODH notebooks" \
    description="Jupyter CUDA tensorflow notebook image with base Python 3.9 builder image based on UBI9 for ODH notebooks" \
    io.k8s.display-name="Jupyter CUDA tensorflow notebook image for ODH notebooks" \
    io.k8s.description="Jupyter CUDA tensorflow notebook image with base Python 3.9 builder image based on UBI9 for ODH notebooks" \
    authoritative-source-url="https://github.com/opendatahub-io/notebooks" \
    io.openshift.build.commit.ref="main" \
    io.openshift.build.source-location="https://github.com/opendatahub-io/notebooks/tree/main/jupyter/tensorflow/ubi8-python-3.9" \
    io.openshift.build.image="quay.io/opendatahub/workbench-images:cuda-jupyter-tensorflow-ubi9-python-3.9"

# Switch to root to be able to install OS packages
USER 0

# Install the CUDA toolkit. The CUDA repos were already defined in the base image
RUN yum -y install cuda-toolkit-11-8 && \
    yum -y clean all  --enablerepo='*'

# Install other NVidia packages: CuDF and CuML
# We have first to remove Elyra, KFP and Streamlit (protobuf version not compatible)
RUN pip uninstall -y kfp kfp-pipeline-spec elyra streamlit kafka-python scikit-learn jupyterlab-git && \
    # Put back JupyterLab Git
    pip install --no-cache-dir --upgrade jupyterlab==3.5.3 jupyterlab-git==0.41.0 && \
    # put Ilan 
    pip install h2o keras lightgbm nltk polars psmpy shap statsmodels tqdm xgboost && \
    pip install tensorflow tensorboard tf2onnx && \
    # Finally install CuDF and CuML
    pip install --no-cache-dir cudf-cu11 cuml-cu11 --extra-index-url=https://pypi.nvidia.com

# Replace Notebook's launcher, "(ipykernel)" with Python's version 3.x.y
#RUN sed -i -e "s/Python.*/$(python --version)\",/" /opt/app-root/share/jupyter/kernels/python3/kernel.json

# Fix permissions to support pip in Openshift environments
RUN chmod -R g+w /opt/app-root/lib/python3.9/site-packages && \
    fix-permissions /opt/app-root -P
