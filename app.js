const { interval, fromEvent, merge, of, Subject } = rxjs;
const { 
  map, filter, scan, bufferCount, switchMap, startWith, 
  takeUntil, distinctUntilChanged, throttleTime, catchError 
} = rxjs.operators;

// ===== Configuração =====
const SENSOR_TYPES = [
  { id: 'temp', name: 'Temperatura', unit: '°C', range: [0, 100] },
  { id: 'humidity', name: 'Umidade', unit: '%', range: [0, 100] },
  { id: 'pressure', name: 'Pressão', unit: 'kPa', range: [90, 110] }
];

// ===== Elementos da UI =====
const sensorGrid = document.getElementById('sensorGrid');
const toggleBtn = document.getElementById('toggleBtn');
const addSensorBtn = document.getElementById('addSensorBtn');
const chartCtx = document.getElementById('historyChart').getContext('2d');

// ===== Controle de Estado =====
const destroy$ = new Subject(); // Para limpeza de recursos
let chart = null;
let sensors = [];

// ===== Funções Auxiliares =====
function generateSensorData(type) {
  const [min, max] = type.range;
  const value = min + Math.random() * (max - min);
  
  // Simula erro (10% de chance)
  if (Math.random() < 0.1) {
    throw new Error(`Falha na leitura do sensor ${type.id}`);
  }
  
  return { 
    type: type.id, 
    value: parseFloat(value.toFixed(2)),
    timestamp: new Date() 
  };
}

function createSensorCard(type) {
  const card = document.createElement('div');
  card.className = 'sensor-card';
  card.id = `sensor-${type.id}`;
  card.innerHTML = `
    <div class="sensor-header">
      <h2>${type.name}</h2>
      <span class="sensor-meta">${type.unit}</span>
    </div>
    <div class="sensor-value">--</div>
    <div class="sensor-status">✅ Conectado</div>
  `;
  sensorGrid.appendChild(card);
  return card;
}

function updateChart(data) {
  if (!chart) {
    chart = new Chart(chartCtx, {
      type: 'line',
      data: { labels: [], datasets: [] },
      options: { responsive: true }
    });
  }

  // Atualiza dados do gráfico (simplificado)
  // (Implementação completa dependeria da estrutura de dados)
}

// ===== Lógica FRP =====
// Controle de pausa
const toggle$ = fromEvent(toggleBtn, 'click').pipe(
  scan(isPaused => !isPaused, false),
  startWith(false)
);

// Stream de sensores dinâmicos
const sensorActions$ = fromEvent(addSensorBtn, 'click').pipe(
  map(() => SENSOR_TYPES[Math.floor(Math.random() * SENSOR_TYPES.length)]),
  distinctUntilChanged((a, b) => a.id === b.id) // Evita duplicatas
);

// Cria streams individuais para cada sensor
sensorActions$.pipe(takeUntil(destroy$)).subscribe(type => {
  const sensorCard = createSensorCard(type);
  
  const sensor$ = interval(1000).pipe(
    takeUntil(destroy$),
    map(() => generateSensorData(type)),
    catchError(err => {
      console.error(err);
      sensorCard.querySelector('.sensor-status').textContent = '❌ Erro';
      return of(null); // Continua o stream mesmo com erro
    }),
    filter(data => data !== null), // Filtra erros
    distinctUntilChanged((a, b) => Math.abs(a.value - b.value) < 0.5) // Anti-oscilação
  );

  // Atualiza UI
  sensor$.subscribe(data => {
    if (!data) return;
    
    const valueElement = sensorCard.querySelector('.sensor-value');
    valueElement.textContent = data.value;
    valueElement.style.color = data.value > type.range[1] * 0.9 
      ? 'var(--danger)' 
      : 'var(--primary)';
    
    // Atualiza gráfico
    sensors.push(data);
    if (sensors.length > 50) sensors.shift(); // Limita histórico
    updateChart(sensors);
  });
});

// Atualiza botão de pausa
toggle$.subscribe(isPaused => {
  toggleBtn.textContent = isPaused ? '▶️ Retomar' : '⏸️ Pausar';
  if (isPaused) destroy$.next(); // Limpa recursos
});

// Limpeza ao sair
window.addEventListener('beforeunload', () => destroy$.next());