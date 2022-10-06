# Install the required packages

packages <- c(
  "tidyverse",
  "readr",
  "plotly",
  "correlation",
  "PerformanceAnalytics",
  "lubridate",
  "kableExtra",
  "lubridate",
  "nortest",
  "car",
  "jtools",
  "olsrr",
  "lmtest",
  "nnet",
  "pROC",
  "foreach"
)

if (sum(as.numeric(!packages %in% installed.packages())) != 0) {
  install_vector <- packages[!packages %in% installed.packages()]
  for (i in seq_along(install_vector)) {
    install.packages(install_vector[i], dependencies = T)
    break()
  }
}

# Load the required packages

load_result <- sapply(packages, require, character = T)

if (sum(as.numeric(!load_result)) == 0) {
  print("All packages loaded")
} else {
  print("Failed to load some packages:")
  print(load_result)
}
