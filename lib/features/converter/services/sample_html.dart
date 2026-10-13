/// Demonstration pages. [landingPageSample] is loaded by the "Sample" button.
const landingPageSample = r'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Aurora Coffee</title>
  <style>
    :root { --brand: #6d4c41; --accent: #ff8f00; }
    * { box-sizing: border-box; }
    body { font-family: Georgia, serif; color: #3e2723; background: #fffaf3; margin: 0; }
    header { display: flex; justify-content: space-between; align-items: center;
             padding: 16px 32px; background: var(--brand); color: #fff; }
    header h1 { font-size: 22px; margin: 0; letter-spacing: 1px; }
    nav { display: flex; gap: 20px; }
    nav a { color: #ffe0b2; text-decoration: none; font-size: 15px; }
    .hero { padding: 56px 32px; text-align: center; color: #fff;
            background: linear-gradient(135deg, #6d4c41 0%, #ff8f00 100%); }
    .hero h2 { font-size: 36px; margin: 0 0 12px; }
    .hero p { font-size: 18px; margin: 0 auto 24px; max-width: 520px; line-height: 1.5; }
    .btn { background: #fff; color: var(--brand); border: none; padding: 12px 28px;
           border-radius: 24px; font-size: 16px; font-weight: bold; }
    .features { display: flex; gap: 20px; padding: 32px; }
    .card { flex: 1; background: #fff; border-radius: 12px; padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.12); border-top: 4px solid var(--accent); }
    .card h3 { margin: 0 0 8px; color: var(--brand); }
    .card p { margin: 0; font-size: 15px; line-height: 1.5; }
    .menu { padding: 0 32px 16px; }
    .menu h2 { color: var(--brand); }
    .menu ul { padding-left: 24px; line-height: 1.8; }
    table { width: 100%; border-collapse: collapse; margin-top: 12px; }
    th, td { border: 1px solid #d7ccc8; padding: 8px 12px; text-align: left; }
    th { background: #efebe9; }
    .contact { margin: 24px 32px; padding: 24px; background: #fff; border-radius: 12px;
               border: 1px solid #d7ccc8; max-width: 480px; }
    .contact label { display: block; font-size: 14px; margin: 12px 0 4px; }
    .contact input, .contact textarea { width: 100%; padding: 10px; border: 1px solid #bcaaa4;
               border-radius: 6px; font-size: 14px; }
    footer { text-align: center; padding: 20px; background: #3e2723; color: #d7ccc8; font-size: 14px; }
    footer a { color: #ffcc80; }
  </style>
</head>
<body>
  <header>
    <h1>AURORA COFFEE</h1>
    <nav>
      <a href="#menu">Menu</a>
      <a href="#about">About</a>
      <a href="#contact">Contact</a>
    </nav>
  </header>

  <section class="hero">
    <h2>Freshly roasted, every morning</h2>
    <p>Small-batch beans from family farms, roasted in-house and delivered to your door.</p>
    <button class="btn">Order now</button>
  </section>

  <section class="features">
    <div class="card">
      <h3>Single origin</h3>
      <p>Traceable beans with <strong>bright, fruity</strong> notes.</p>
    </div>
    <div class="card">
      <h3>Slow roasted</h3>
      <p>Balanced and <em>smooth</em>, never bitter.</p>
    </div>
    <div class="card">
      <h3>Fair trade</h3>
      <p>We pay farmers well &mdash; and it shows in the cup.</p>
    </div>
  </section>

  <section class="menu" id="menu">
    <h2>Today's menu</h2>
    <ul>
      <li>Espresso &ndash; $3.00</li>
      <li>Flat white &ndash; $4.20</li>
      <li>Cold brew &ndash; $4.50</li>
    </ul>
    <table>
      <tr><th>Size</th><th>Price</th><th>Calories</th></tr>
      <tr><td>Small</td><td>$3.50</td><td>120</td></tr>
      <tr><td>Large</td><td>$4.80</td><td>210</td></tr>
    </table>
  </section>

  <section class="contact" id="contact">
    <h2 style="margin-top:0">Say hello</h2>
    <label>Your name</label>
    <input type="text" placeholder="Jane Doe">
    <label>Message</label>
    <textarea rows="3" placeholder="How can we help?"></textarea>
    <p style="margin-bottom:0"><button class="btn" style="background:#6d4c41;color:#fff">Send</button></p>
  </section>

  <footer>
    &copy; 2026 Aurora Coffee &middot; <a href="#top">Back to top</a>
  </footer>
</body>
</html>
''';
