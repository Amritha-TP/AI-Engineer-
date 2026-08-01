/**
 * CIFAR-10 Flask Web Application - Client-Side Interactive Engine
 * Handles Drag & Drop, Theme State, Chart.js Probability Charts, Grad-CAM toggle
 */

document.addEventListener("DOMContentLoaded", () => {
  initTheme();
  initDragAndDrop();
  initImagePreview();
});

/* ==========================================================================
   1. Dark Mode Theme Controller
   ========================================================================== */
function initTheme() {
  const storedTheme = localStorage.getItem("theme") || "light";
  document.documentElement.setAttribute("data-theme", storedTheme);
  updateThemeIcon(storedTheme);

  const toggleBtn = document.getElementById("themeToggleBtn");
  if (toggleBtn) {
    toggleBtn.addEventListener("click", () => {
      const currentTheme = document.documentElement.getAttribute("data-theme");
      const newTheme = currentTheme === "dark" ? "light" : "dark";
      document.documentElement.setAttribute("data-theme", newTheme);
      localStorage.setItem("theme", newTheme);
      updateThemeIcon(newTheme);

      // Re-render chart colors if active chart exists
      if (window.cifarChart) {
        updateChartColors(window.cifarChart, newTheme);
      }
    });
  }
}

function updateThemeIcon(theme) {
  const icon = document.getElementById("themeIcon");
  const label = document.getElementById("themeLabel");
  if (icon) {
    icon.className = theme === "dark" ? "bi bi-sun-fill text-warning" : "bi bi-moon-stars-fill text-primary";
  }
  if (label) {
    label.textContent = theme === "dark" ? "Light Mode" : "Dark Mode";
  }
}

/* ==========================================================================
   2. Drag and Drop File Upload
   ========================================================================== */
function initDragAndDrop() {
  const dropzone = document.getElementById("uploadDropzone");
  const fileInput = document.getElementById("imageFileInput");

  if (!dropzone || !fileInput) return;

  ["dragenter", "dragover", "dragleave", "drop"].forEach((eventName) => {
    dropzone.addEventListener(eventName, preventDefaults, false);
  });

  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  ["dragenter", "dragover"].forEach((eventName) => {
    dropzone.addEventListener(eventName, () => dropzone.classList.add("dragover"), false);
  });

  ["dragleave", "drop"].forEach((eventName) => {
    dropzone.addEventListener(eventName, () => dropzone.classList.remove("dragover"), false);
  });

  dropzone.addEventListener("drop", (e) => {
    const dt = e.dataTransfer;
    const files = dt.files;
    if (files.length > 0) {
      fileInput.files = files;
      handleFileSelected(files[0]);
    }
  });

  dropzone.addEventListener("click", () => {
    fileInput.click();
  });

  fileInput.addEventListener("change", (e) => {
    if (e.target.files.length > 0) {
      handleFileSelected(e.target.files[0]);
    }
  });
}

/* ==========================================================================
   3. Live Image Preview & Validation
   ========================================================================== */
function handleFileSelected(file) {
  const allowedTypes = ["image/jpeg", "image/jpg", "image/png"];
  const maxSize = 5 * 1024 * 1024; // 5 MB

  const errorAlert = document.getElementById("uploadErrorAlert");
  if (errorAlert) errorAlert.classList.add("d-none");

  if (!allowedTypes.includes(file.type)) {
    showError("Invalid file type. Only JPG, JPEG, and PNG images are allowed.");
    return;
  }

  if (file.size > maxSize) {
    showError(`File size exceeds 5 MB limit. (Uploaded: ${(file.size / (1024 * 1024)).toFixed(2)} MB)`);
    return;
  }

  const reader = new FileReader();
  reader.onload = (e) => {
    const previewImg = document.getElementById("previewImg");
    const previewContainer = document.getElementById("imagePreviewContainer");
    const filenameDisplay = document.getElementById("selectedFilename");
    const submitBtn = document.getElementById("predictSubmitBtn");

    if (previewImg && previewContainer) {
      previewImg.src = e.target.result;
      previewContainer.classList.remove("d-none");
    }
    if (filenameDisplay) {
      filenameDisplay.textContent = `${file.name} (${(file.size / 1024).toFixed(1)} KB)`;
    }
    if (submitBtn) {
      submitBtn.removeAttribute("disabled");
    }
  };
  reader.readAsDataURL(file);
}

function showError(message) {
  const errorAlert = document.getElementById("uploadErrorAlert");
  const errorText = document.getElementById("uploadErrorText");
  if (errorAlert && errorText) {
    errorText.textContent = message;
    errorAlert.classList.remove("d-none");
  }
}

function initImagePreview() {
  const uploadForm = document.getElementById("uploadForm");
  if (uploadForm) {
    uploadForm.addEventListener("submit", () => {
      const submitBtn = document.getElementById("predictSubmitBtn");
      if (submitBtn) {
        submitBtn.setAttribute("disabled", "true");
        submitBtn.innerHTML = `<span class="spinner-border spinner-border-sm me-2"></span> Classifying Image...`;
      }
    });
  }
}

/* ==========================================================================
   4. Chart.js Horizontal Bar Chart Generator
   ========================================================================== */
function renderProbabilityChart(canvasId, labels, dataValues) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;

  const ctx = canvas.getContext("2d");
  const isDark = document.documentElement.getAttribute("data-theme") === "dark";

  const textColor = isDark ? "#F8FAFC" : "#0F172A";
  const gridColor = isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.06)";

  window.cifarChart = new Chart(ctx, {
    type: "bar",
    data: {
      labels: labels,
      datasets: [
        {
          label: "Probability (%)",
          data: dataValues,
          backgroundColor: dataValues.map((val) =>
            val === Math.max(...dataValues)
              ? "rgba(34, 197, 94, 0.85)" // Highlight max with Emerald Accent
              : "rgba(79, 70, 229, 0.75)"  // Primary Indigo
          ),
          borderColor: dataValues.map((val) =>
            val === Math.max(...dataValues) ? "#16A34A" : "#4F46E5"
          ),
          borderWidth: 1.5,
          borderRadius: 6,
        },
      ],
    },
    options: {
      indexAxis: "y",
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: (context) => ` Probability: ${context.parsed.x.toFixed(2)}%`,
          },
        },
      },
      scales: {
        x: {
          beginAtZero: true,
          max: 100,
          ticks: {
            color: textColor,
            callback: (value) => `${value}%`,
          },
          grid: { color: gridColor },
        },
        y: {
          ticks: {
            color: textColor,
            font: { family: "'Outfit', sans-serif", weight: "600" },
          },
          grid: { display: false },
        },
      },
    },
  });
}

function updateChartColors(chart, theme) {
  const isDark = theme === "dark";
  const textColor = isDark ? "#F8FAFC" : "#0F172A";
  const gridColor = isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.06)";

  chart.options.scales.x.ticks.color = textColor;
  chart.options.scales.x.grid.color = gridColor;
  chart.options.scales.y.ticks.color = textColor;
  chart.update();
}
