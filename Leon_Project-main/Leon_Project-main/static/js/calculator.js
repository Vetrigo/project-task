let display = document.getElementById('display');
let currentInput = '0';

function appendToDisplay(value) {
    if (currentInput === '0' && value !== '.') {
        currentInput = value;
    } else {
        currentInput += value;
    }
    display.textContent = currentInput;
}

function clearDisplay() {
    currentInput = '0';
    display.textContent = currentInput;
    document.getElementById('result').style.display = 'none';
}

async function calculate() {
    try {
        const expression = currentInput.replace(/×/g, '*').replace(/−/g, '-');
        const response = await fetch('/calculate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ expression: expression })
        });
        
        const data = await response.json();
        const resultDiv = document.getElementById('result');
        
        if (data.error) {
            resultDiv.className = 'result error';
            resultDiv.textContent = 'Error: ' + data.error;
        } else {
            resultDiv.className = 'result';
            resultDiv.textContent = 'Result: ' + data.result;
            currentInput = String(data.result);
            display.textContent = currentInput;
        }
        resultDiv.style.display = 'block';
    } catch (error) {
        const resultDiv = document.getElementById('result');
        resultDiv.className = 'result error';
        resultDiv.textContent = 'Error: ' + error.message;
        resultDiv.style.display = 'block';
    }
}

