FROM quay.io/powercloud/powervs-container-host:multi-arch

LABEL authors="Rafael Sene - rpsene@br.ibm.com"

WORKDIR /ocp-import

RUN ibmcloud plugin update power-iaas --force

ENV API_KEY=""
ENV POWERVS_CRN=""
ENV IMAGE_NAME=""
ENV IMAGE_FILE_NAME=""
ENV OS_TYPE=""
ENV DISK_TYPE=""
ENV ACCESS_KEY=""
ENV SECRET_KEY=""
ENV BUCKET=""
ENV BUCKET_ACCESS=""
ENV REGION=""

COPY ./import.sh .

RUN chmod +x ./import.sh

ENTRYPOINT ["/bin/bash", "-c", "./import.sh"]