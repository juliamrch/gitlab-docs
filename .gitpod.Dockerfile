FROM gitpod/workspace-full:2024-06-03-17-43-12

RUN brew install hadolint

# hadolint ignore=DL3004,DL3059
RUN sudo install-packages yamllint shellcheck
