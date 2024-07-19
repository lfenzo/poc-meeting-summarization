# Meeting Summarization Proof of Concept

This repository contains a proof of concept for summarizing meeting recordings. The process involves two main steps: transcribing and diarizing the audio with [WhisperX](https://github.com/m-bain/whisperX), followed by summarizing the resulting dialogue with [Gemma 2](https://blog.google/technology/developers/google-gemma-2/) (via [`llama-cpp-python`](https://github.com/abetlen/llama-cpp-python)) to extract the most relevant information. Each step is executed within its own Podman container to ensure isolation of dependencies.

## Installation and Organization

Before installing from the repository, make sure you have [`podman`](https://podman.io/),
[`podman-compose`](https://github.com/containers/podman-compose), and the [`nvidia-container-toolkit`](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) (mandatory for GPU access inside the containers) installed on your system.

**Before running the commands below, make sure you have set the `ENV` file with your [Hugging Face Access Token](https://huggingface.co/docs/hub/security-tokens)** as this token is necessary to download from Hugging Face some of the models used in this project.

```bash
git clone git@github.com:lfenzo/poc-meeting-summarization.git
cd poc-meeting-summarization
podman compose up --build
```

After the build process, two containers sharing a common directory `outputs/` are spawned to encapsulate the diarization and summarization processes. Each container hosts a Jupyter Lab server which can be accessed via the web browser on ports `8888` (Diarization) and `8889` (Summarization) through `localhost`. The following two sections show details about each of the containers contents and organization.

### Diarization Container

As a source for audio, some YouTube videos with multiple speakers in meeting contexts were used. These video audios are stored in the `audios/` directory after being downloaded by `download-audios-from-youtube.ipynb` (check out this notebook to add other meetings you may want to summarize as YouTube links); or, **if you have your meeting audio, you may just place it in this directory** and modify the `run-diarization.ipynb` to point to the added audio file.

```
diarization/
├── audios/
│   ├── video1.mp3
│   ├── ...
│   └── video5.mp3
├── Containerfile
├── download-audios-from-youtube.ipynb
├── environment.yaml
├── models/
└── run-diarization.ipynb
```

After being processed by `run-diarization.ipynb`, the outputs are placed under `outputs/<video_name>` in the root of the Git repository. Additionally, the `models/` directory stores the models automatically downloaded by `whisperx` so that we don't need to download them every time the containers are launched (as by default they are place in `/.cache/` and get wiped out every time the container relaunches).

### Summarization Container

```
summarization/
├── Containerfile
├── models
│   ├── ...
│   └── gemma-2-27b-it-Q5_K_L.gguf
├── requirements.txt
└── run-summarization.ipynb
```

The `models/` directory serves the same purpose as in the Diarization container. If you wish to use another `llama-cpp-python`-compatible model, check the `run-summarization.ipynb` notebook and replace the `filename` and `repo_id` variables accordingly. Once again, to prevent re-downloading large models multiple times, the local LLMs are downloaded to this directory and **persist in disk even after `podman compose down`.**

> [!TIP]
> Depending on the length of your transcription, you may want to tune the `n_ctx` parameter in your summarization model, as this may degrade the summary quality and/or exceed your GPU VRAM.

**Once completed, the summaries are placed in `outputs/<your_video_name>/summary.txt` files.**

## Versions

This proof of concept was tested with the following software versions:
- `podman` 5.1.1
- `nvidia-container-toolkit` 1.16.0
- Linux Kernel: 6.9.9

Check the `Containerfile`s for each base image version.
