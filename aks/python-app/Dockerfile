# Use an official Python runtime as a parent image
FROM python:3.9.14-slim
WORKDIR /app
ADD . /app
RUN pip install --trusted-host files.pythonhosted.org --trusted-host pypi.org --trusted-host pypi.python.org Flask
ENV NAME World
CMD ["python", "app.py"]

 