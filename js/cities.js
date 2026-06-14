// Carrega cidades ativas do Supabase num <select>
async function loadActiveCities(selectId, placeholder = 'Selecione a cidade') {
  const sel = document.getElementById(selectId);
  sel.innerHTML = `<option value="">Carregando...</option>`;
  sel.disabled  = true;

  const { data, error } = await supabase
    .from('active_cities')
    .select('name')
    .order('name');

  sel.innerHTML = `<option value="">${placeholder}</option>`;
  if (!error && data) {
    data.forEach(c => sel.appendChild(new Option(c.name, c.name)));
  }
  sel.disabled = false;
}
