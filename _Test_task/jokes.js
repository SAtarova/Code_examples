const objJobButton = document.querySelector('.joke_btn')
const listJokes = []

function FillStructure(result) {
    const jokeStructure = {}

    jokeStructure.type = result.type
    jokeStructure.setup = result.setup    
    jokeStructure.punchline = result.punchline
    jokeStructure.id = result.id

    listJokes.push(jokeStructure)
}

objJobButton.addEventListener('click', (e) => {

    fetch('https://official-joke-api.appspot.com/random_joke', {method: 'GET'})
        .then((res) => res.json())
        .then((result) => {
            FillStructure(result)
        })
})
