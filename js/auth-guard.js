// Protege páginas admin - redireciona se não estiver logado
(function() {
  const session = localStorage.getItem('admin_session');
  if (!session) {
    window.location.href = '../admin-login.html';
  }
})();

function getAdminUser() {
  return localStorage.getItem('admin_session') || '';
}

function logout() {
  localStorage.removeItem('admin_session');
  window.location.href = '../admin-login.html';
}
