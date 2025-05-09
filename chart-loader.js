function loadChartJS() {
    return new Promise((resolve) => {
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/chart.js';
      script.onload = resolve;
      document.head.appendChild(script);
    });
  }
  
  loadChartJS().then(() => {
    console.log('Chart.js carregado!');
  });