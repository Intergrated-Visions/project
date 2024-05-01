const baseUrl = 'https://wger.de/';
const select = document.querySelector('select');
const button = document.querySelector('button');
const section = document.querySelector('section');
const checkbox = document.querySelector('#equipment');
const introText = document.querySelector('.intro-text');
let savedItems = [];

if (JSON.parse(localStorage.getItem('savedExercises')) !== null) {
  savedItems = JSON.parse(localStorage.getItem('savedExercises'));
}

window.onload = function() {
  const exerciseCategories = [
    {
      id: 10,
      name: 'Abs'
    },
    {
      id: 8,
      name: 'Arms'
    },
    {
      id: 12,
      name: 'Back'
    },
    {
      id: 14,
      name: 'Calves'
    },
    {
      id: 11,
      name: 'Chest'
    },
    {
      id: 9,
      name: 'Legs'
    },
    {
      id: 13,
      name: 'Shoulders'
    }
  ];

  exerciseCategories.forEach(category => {
    const option = document.createElement('option');

    option.innerText = category.name;
    option.value = category.id;
    select.appendChild(option);
  });
};

button.addEventListener('click', async () => {
  let userOptions = select.value;

  if (checkbox.checked) {
    userOptions += '&equipment=7';
  }

  const res = await axios.get(
    `${baseUrl}api/v2/exercise/?language=2&category=${userOptions}&status=2&limit=100`
  );

  section.innerHTML = ``;

  if (res.data.count === 0) {
    section.innerHTML = `<p style="margin-top: 3em;">I don't have anything for you... Don't just stare at me, pick something else.</p>`;
    return;
  }

  const randomExercise = getRandom(res.data.results);
  const container = document.createElement('div');
  container.setAttribute('class', 'exercise-container');
  const title = document.createElement('h3');
  title.innerText = randomExercise.name;
  container.appendChild(title);

  container.innerHTML += `${randomExercise.description}`;
  await getImage(randomExercise.id, container);

  const saveBtn = document.createElement('button');
  saveBtn.setAttribute('class', 'save-button');

  if (isSaved(savedItems, randomExercise).length > 0) {
    saveBtn.innerText = 'Saved';
    saveBtn.disabled = 'true';
  } else {
    saveBtn.innerText = 'Save';
  }

  saveBtn.addEventListener('click', () => {
    savedItems.push(randomExercise);
    saveExercise(savedItems);
    saveBtn.innerText = 'Saved!';
    saveBtn.disabled = 'true';
  });

  container.appendChild(saveBtn);
  section.appendChild(container);
});

// Helper functions
function getRandom(arr) {
  const randomExercise = arr[Math.floor(Math.random() * arr.length)];
  return randomExercise;
}

function isSaved(savedItems, randomExercise) {
  const found = savedItems.filter(saved => saved.id === randomExercise.id);
  return found;
}

function saveExercise(arr) {
  if (arr.length > 0) {
    localStorage.setItem('savedExercises', JSON.stringify(arr));
  }
}

async function getImage(id, container) {
  let imageUrl = '';
  const image = document.createElement('img');
  const res = await axios.get(`${baseUrl}api/v2/exerciseimage/?exercise=${id}`);

  if (res.data.results.length > 0) {
    imageUrl = res.data.results[0].image;
    image.setAttribute('src', imageUrl);
    container.appendChild(image);
  } else {
    return;
  }
}
