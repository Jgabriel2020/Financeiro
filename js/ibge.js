const IBGE = 'https://servicodados.ibge.gov.br/api/v1/localidades';

async function loadStates(stateEl) {
  stateEl.innerHTML = '<option value="">Carregando estados...</option>';
  stateEl.disabled = true;
  try {
    const res = await fetch(`${IBGE}/estados?orderBy=nome`);
    const data = await res.json();
    stateEl.innerHTML = '<option value="">Selecione o estado</option>';
    data.forEach(s => stateEl.appendChild(new Option(`${s.nome} (${s.sigla})`, s.sigla)));
    stateEl.disabled = false;
  } catch {
    stateEl.innerHTML = '<option value="">Erro ao carregar</option>';
    stateEl.disabled = false;
  }
}

async function loadCities(uf, cityEl) {
  cityEl.innerHTML = '<option value="">Carregando cidades...</option>';
  cityEl.disabled = true;
  try {
    const res = await fetch(`${IBGE}/estados/${uf}/municipios?orderBy=nome`);
    const data = await res.json();
    cityEl.innerHTML = '<option value="">Selecione a cidade</option>';
    data.forEach(c => cityEl.appendChild(new Option(c.nome, c.nome)));
    cityEl.disabled = false;
  } catch {
    cityEl.innerHTML = '<option value="">Erro ao carregar</option>';
    cityEl.disabled = false;
  }
}

// Inicializa par estado/cidade num formulário
function setupStateCityPair(stateId, cityId) {
  const stateEl = document.getElementById(stateId);
  const cityEl  = document.getElementById(cityId);
  loadStates(stateEl);
  stateEl.addEventListener('change', () => {
    if (stateEl.value) {
      loadCities(stateEl.value, cityEl);
    } else {
      cityEl.innerHTML = '<option value="">Selecione o estado primeiro</option>';
      cityEl.disabled = true;
    }
  });
}
