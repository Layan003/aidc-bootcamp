FROM python:3.11-slim

# Create a non-root user and pre-create the Hugging Face cache directory with correct ownership
RUN useradd --create-home app && \
    mkdir -p /home/app/.cache/huggingface && \
    chown -R app:app /home/app

# Set environment variables for Hugging Face cache
ENV HF_HOME=/home/app/.cache/huggingface
ENV TRANSFORMERS_CACHE=/home/app/.cache/huggingface

WORKDIR /app

# Layer cache optimization: requirements first
COPY app/requirements.txt .
RUN pip install --no-cache-dir \
      --index-url https://download.pytorch.org/whl/cpu \
      --extra-index-url https://pypi.org/simple \
      -r requirements.txt

# Application code second
COPY --chown=app:app app/ .

# Switch to non-root user
USER app

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]