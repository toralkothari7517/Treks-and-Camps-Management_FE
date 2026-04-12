document.addEventListener('DOMContentLoaded', function () {
  const filters = document.querySelectorAll('.filter-link');
  const selectedDifficulty = new URLSearchParams(window.location.search).get('difficulty') || '';

  filters.forEach(link => {
    const difficulty = link.dataset.difficulty;
    if (difficulty === selectedDifficulty) {
      link.classList.remove('btn-outline-success');
      link.classList.add('btn-success', 'text-white');
    }

    link.addEventListener('click', function (event) {
      event.preventDefault();
      window.location.href = '/treks' + (difficulty ? '?difficulty=' + difficulty : '');
    });
  });
});
