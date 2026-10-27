# Image for running video_face_tagger.py next to the archive, e.g. on a NAS.
# The build context is this package directory:
#
#   docker build -t video-face-tagger photo_archive
#
# See the README for the run commands.
FROM python:3.14-slim

# HOME holds ~/.config/video_face_tagger (face model, generated ExifTool_config).
# It is made world-writable so the container can run as any uid (--user).
# OPENCV_LOG_LEVEL silences a harmless per-thread OpenCV 5 warning about
# setPreferableTarget.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=America/New_York \
    HOME=/home/tagger \
    OPENCV_LOG_LEVEL=ERROR

# System dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        libimage-exiftool-perl \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies (face pre-filter)
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Application
WORKDIR /app
COPY . /app/photo_archive

# Download the face detection model into the image
RUN mkdir -p "${HOME}" \
    && python -m photo_archive.video_face_tagger fetch-model \
    && chmod -R a+rwX "${HOME}"

ENTRYPOINT ["python", "-m", "photo_archive.video_face_tagger"]
CMD ["--help"]
