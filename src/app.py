import os
from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

# Configuration
app.config['DEBUG'] = os.environ.get('FLASK_ENV') == 'development'

@app.route('/')
def index():
    """Render the calculator UI"""
    return render_template('index.html')

@app.route('/calculate', methods=['POST'])
def calculate():
    """Calculate the result of a mathematical expression"""
    try:
        data = request.get_json()
        expression = data.get('expression', '')

        if not expression:
            return jsonify({'error': 'Empty expression'}), 400

        # Sanitize the expression - only allow numbers, operators, and parentheses
        allowed_chars = set('0123456789+-*/.() ')
        if not all(c in allowed_chars for c in expression):
            return jsonify({'error': 'Invalid characters in expression'}), 400

        # Evaluate the expression safely
        try:
            result = eval(expression)
            # Handle division by zero
            if isinstance(result, float) and (result == float('inf') or result == float('-inf')):
                return jsonify({'error': 'Division by zero'}), 400
            return jsonify({'result': result})
        except ZeroDivisionError:
            return jsonify({'error': 'Division by zero'}), 400
        except SyntaxError:
            return jsonify({'error': 'Invalid expression syntax'}), 400
        except Exception as e:
            return jsonify({'error': str(e)}), 400

    except Exception as e:
        return jsonify({'error': 'Server error: ' + str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    # This block only runs when running the app directly (not with Gunicorn)
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=8000, debug=debug_mode)

