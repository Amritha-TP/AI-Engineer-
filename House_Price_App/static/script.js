document.addEventListener("DOMContentLoaded", function () {
    
    // Theme Toggle Logic
    const themeToggleBtn = document.getElementById("theme-toggle");
    const htmlElement = document.documentElement;
    const themeIcon = themeToggleBtn ? themeToggleBtn.querySelector("i") : null;

    // Check local storage for theme
    const savedTheme = localStorage.getItem("theme") || "light";
    htmlElement.setAttribute("data-bs-theme", savedTheme);
    updateThemeIcon(savedTheme);

    if (themeToggleBtn) {
        themeToggleBtn.addEventListener("click", () => {
            const currentTheme = htmlElement.getAttribute("data-bs-theme");
            const newTheme = currentTheme === "light" ? "dark" : "light";
            htmlElement.setAttribute("data-bs-theme", newTheme);
            localStorage.setItem("theme", newTheme);
            updateThemeIcon(newTheme);
        });
    }

    function updateThemeIcon(theme) {
        if (!themeIcon) return;
        if (theme === "dark") {
            themeIcon.classList.remove("fa-moon");
            themeIcon.classList.add("fa-sun");
        } else {
            themeIcon.classList.remove("fa-sun");
            themeIcon.classList.add("fa-moon");
        }
    }

    // Form Validation and Spinner Logic
    const form = document.getElementById("prediction-form");
    const predictBtn = document.getElementById("predict-btn");
    const btnText = document.getElementById("btn-text");
    const btnSpinner = document.getElementById("btn-spinner");

    if (form) {
        form.addEventListener("submit", function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            } else {
                // Show spinner
                if (predictBtn) {
                    predictBtn.setAttribute("disabled", "true");
                    btnText.classList.add("d-none");
                    btnSpinner.classList.remove("d-none");
                }
            }
            form.classList.add("was-validated");
        }, false);
    }

    // PDF Download Logic
    const downloadPdfBtn = document.getElementById("download-pdf");
    if (downloadPdfBtn) {
        downloadPdfBtn.addEventListener("click", function () {
            const element = document.getElementById("pdf-content");
            const opt = {
                margin:       0.5,
                filename:     'house-price-prediction.pdf',
                image:        { type: 'jpeg', quality: 0.98 },
                html2canvas:  { scale: 2, useCORS: true },
                jsPDF:        { unit: 'in', format: 'letter', orientation: 'portrait' }
            };
            
            // Temporarily hide the buttons for PDF generation
            const buttons = element.querySelector('.d-grid');
            if (buttons) buttons.style.display = 'none';

            html2pdf().set(opt).from(element).save().then(() => {
                // Restore buttons
                if (buttons) buttons.style.display = 'flex';
            });
        });
    }
});
