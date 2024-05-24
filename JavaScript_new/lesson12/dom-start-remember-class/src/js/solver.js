const objParent  = document.querySelector('.task-block')
const objButtons = objParent.querySelectorAll('button')
const objInput = [...objParent.querySelectorAll('input')]
const inputElem = document.querySelector('.increase-decrease')

objButtons.forEach(item => {
    item.addEventListener('click', () => {
        if (item.className == 'decrease-btn counter-btn') {            
            if (objInput[0].value == 0) {
                alert('Counter is min')
            }
            else {
                objInput[0].value--
            }              
        }
        if (item.className == 'increase-btn counter-btn') {
         
            if (inputElem.value === "10") {
                alert('Counter is max')
            } else {
                inputElem.value++
            }                
        }
    })
})

let objArray = []
let objElem = {}
objElem.id    = 0
const objParentForm = document.querySelector('.form-comment')
const objInputs = objParentForm.querySelectorAll('input')
const objButton = objParentForm.querySelectorAll('button')[0]

objButton.addEventListener('click', () => {
    console.log(objInputs[0].value)
    objElem = {}
    if (objInputs[0].value != '' &&
        objInputs[1].value != '' &&
        objInputs[2].value != '' &&
        objInputs[3].value != '') {

        console.log('IN')

        objElem.id++
        objElem.title  = objInputs[0].value
        objElem.body   = objInputs[1].value
        objElem.rating = objInputs[2].value
        objElem.author = objInputs[3].value

        console.log(objElem)

        objArray.push(objElem)

        objInputs.forEach(item => item.value = '')

        console.log(objArray)
    }
    else {
        alert ('You should fill all fields')
    }
})


const objParentComment = document.querySelector('.comments')
const objInputComments = document.querySelector('.comment-form').querySelectorAll('input')
const objButtonComment = document.querySelector('.comment-form-button')
const objParentComm = objParentComment.querySelectorAll('.comment')
objArray = []

objButtonComment.addEventListener('click', () => {  
    objElem = {}
    if (![...objInputComments].some(item => item.value === '' || item.value === ' ')) {
        console.log(objInputComments)
        objElem.title = objInputComments[0].value
        objElem.body = objInputComments[1].value.length > 55 ? objInputComments[1].value.slice(0, 54) + '...' : objInputComments[1].value
        objElem.rating = objArray.some(item => item.author === objInputComments[3].value) ? '5' : objInputComments[2].value
        objElem.author = objInputComments[3].value

        console.log(objElem)

        objArray.push(objElem)

    } else {
        alert('You should fill all fields')
    }
    
})

const newsArray = [
    {
        userId: 1,
        id: 1,
        title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
        author: 'Alex',
        body: "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
    },
    {
        userId: 1,
        id: 2,
        title: "qui est esse",
        author: 'Anna',
        body: "est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae ea dolores neque fugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis qui aperiam non debitis possimus qui neque nisi nulla"
    },
    {
        userId: 1,
        id: 3,
        title: "ea molestias quasi exercitationem repellat qui ipsa sit aut",
        author: 'Nina',
        body: "et iusto sed quo iure voluptatem occaecati omnis eligendi aut ad voluptatem doloribus vel accusantium quis pariatur molestiae porro eius odio et labore et velit aut"
    },
    {
        userId: 1,
        id: 4,
        title: "eum et est occaecati",
        author: 'Alex',
        body: "ullam et saepe reiciendis voluptatem adipisci sit amet autem assumenda provident rerum culpa quis hic commodi nesciunt rem tenetur doloremque ipsam iure quis sunt voluptatem rerum illo velit"
    },
]

let parentDiv2 = document.querySelector('.news')
let allPosts = document.querySelectorAll('.post')
const objButtonComment2 = document.querySelector('.get-posts.new-btn')

class PostsDivs {
    constructor(title, body, author) {
        this.title  = title;
        this.body   = body;
        this.author = author
    }
    MakeTag() {
        let outputTag = `
        <div class="post">
            <p class="post-title">${this.title}</p>
            <p class="post-body">${this.body}</p>
            <p class="post-author">Author: ${this.author}</p>
        </div >`;

        return outputTag;
    }    
}

objButtonComment2.addEventListener('click', () => {
    for (i = 0; i < newsArray.length; i++) {

        let objPostDiv = new PostsDivs(newsArray[i].title, newsArray[i].body, newsArray[i].author)
        const BodyPost = objPostDiv.MakeTag()

        /*const BodyPost = `
            <div class="post"
                <p class="post-title">${newsArray[i].title}</p>
                <p class="post-body">${newsArray[i].body}</p>
                <p class="post-author">Author: ${newsArray[i].author}</p>
            </div>`*/

        parentDiv2.insertAdjacentHTML('beforeend', BodyPost)

    }
})


const objButtonComment3 = document.querySelector('.sort-title.new-btn')

objButtonComment3.addEventListener('click', () => {

    let parentDiv3 = document.querySelector('.news')
    let allPosts   = document.querySelectorAll('.post')

    if (parentDiv3) {

        allPosts.forEach(item => { item.remove('.post') })

        newsArray
            .sort((item1, item2) => item1.title > item1.title ? 1 : -1)
            .forEach(item => {
                let objPostDiv2 = new PostsDivs(item.title, item.body, item.author)
                const BodyPost2 = objPostDiv2.MakeTag()                

                parentDiv3.insertAdjacentHTML('beforeend', BodyPost2)
            })
        
    }

})

const objButtonPosts4 = document.querySelector('.select-name')

objButtonPosts4.addEventListener('change', () => {

    let parentDiv3 = document.querySelector('.news')
    let allPosts = document.querySelectorAll('.post')
    const nameSelect     = document.querySelector('.select-name')
    const selectedOption = nameSelect.options[nameSelect.selectedIndex];

    if (parentDiv3) {

        allPosts.forEach(item => { item.remove('.post') })

        newsArray
            .sort((item1, item2) => item1.title > item1.title ? 1 : -1)
            .forEach(item => {
                //let currentPostAuthor = item.querySelectorAll('.post-author')[0].textContent.slice(8,)
                //console.log(currentPostAuthor)

                if (selectedOption.value === item.author) {
                    let objPostDiv3 = new PostsDivs(item.title, item.body, item.author)
                    const BodyPost3 = objPostDiv3.MakeTag()

                    parentDiv3.insertAdjacentHTML('beforeend', BodyPost3)
                }
        })
    }

})

const objButtonPosts5 = document.querySelector('.delete-all.new-btn')

objButtonPosts5.addEventListener('click', () => {

    let allPosts = document.querySelectorAll('.post')

    if (parentDiv2) {
        allPosts.forEach(item => { item.remove('.post') })
    }
})

// Accordions tasks


const objAllAccordions = document.querySelector('.accordions')

objAllAccordions.onclick = function (event) {

    let objTarget = event.target

    const objButtonAccordions = [...objAllAccordions.querySelectorAll('.accordion')]  

    for (let i = 0; i < objButtonAccordions.length; i++) {

        let currentAccordion = [...objButtonAccordions[i].querySelectorAll(".accordion__question")][0]

        let currentAccordionBlock = [...objButtonAccordions[i].querySelectorAll(".accordion__question-block")][0]

        if (currentAccordion == objTarget || currentAccordionBlock == objTarget) { 

            let currentAccordionAnswer = [...objButtonAccordions[i].querySelectorAll(".accordion__answer, .accordion__answer_active")]

            for (answerVariant of currentAccordionAnswer) {
                if (answerVariant) currentAccordionAnswer = answerVariant
            }

            if (currentAccordionAnswer.classList.contains("accordion__answer")) {                
                currentAccordionAnswer.className = "accordion__answer_active" 
            }
            else {
                currentAccordionAnswer.className = "accordion__answer"
                
                
            }
            objButtonAccordions[i].querySelector(".accordion__question-block").classList.toggle('accordion__question-block_active')
        }
    }
    
}

// TODO list

const buttonAddTask = document.querySelector('.todo-icon.add-new-icon')
const buttonRemoveAllTasks = document.querySelector('.todo-icon.remove-all-icon')
const tasksParent = document.querySelector('.todo-list')
const tasksItemParent = document.querySelector('todo-list__item')
const tasksActionParent = document.querySelector('.todo-list__item-actions')

buttonAddTask.addEventListener('click', () => {

    const newTask = `<li class="todo-list__item">
                            <input type="text" class="todo-list__item-text" readonly="readonly">
                            <div class="todo-list__item-actions">
                                <img class="todo-list__item-actions-icon check-list-icon" src="./img/icons/check-icon.svg" alt="">
                                <img class="todo-list__item-actions-icon edit-list-icon" src="./img/icons/edit-icon.svg" alt="">
                                <img class="todo-list__item-actions-icon delete-list-icon" src="./img/icons/delete-icon.svg" alt="">
                            </div>
                        </li>`
    if (tasksParent) {
        tasksParent.insertAdjacentHTML("afterbegin", newTask)
    }
})

buttonRemoveAllTasks.addEventListener('click', () => {

    let allTasks = document.querySelectorAll('.todo-list__item')

    if (tasksParent) {
        allTasks.forEach(item => { item.remove('.todo-list__item') })
    }
})

tasksParent.onclick = function (event) {

    const listItems = [...tasksParent.querySelectorAll('.todo-list__item-actions')]
    let objTarget = event.target

    for (i = 0; i < listItems.length; i++) {        

        let currentButtonRemove = [...listItems[i].querySelectorAll('.todo-list__item-actions-icon.delete-list-icon')][0]
        let currentButtonEdit = [...listItems[i].querySelectorAll('.todo-list__item-actions-icon.edit-list-icon')][0]
        let currentButtonDone = [...listItems[i].querySelectorAll('.todo-list__item-actions-icon.check-list-icon')][0]
        let currentParent = listItems[i].parentElement

        if (currentButtonRemove == objTarget) {
            currentParent.remove()
        }
        if (currentButtonEdit == objTarget) {            
            let currentInput = [...currentParent.querySelectorAll('.todo-list__item-text', '.todo - list__item - text_edit')][0]

            if (currentInput.className == 'todo-list__item-text') {
                currentInput.removeAttribute('readonly')                
                currentInput.focus()
            }
            else {
                currentInput.setAttribute('readonly', 'readonly')
            }
            currentParent.querySelector(".todo-list__item-text").classList.toggle('todo-list__item-text_edit')

        }
        if (currentButtonDone == objTarget) {
            currentParent.querySelector(".todo-list__item-text").classList.toggle('todo-list__item-text_checked')
            // !!!!!! TODO
            currentParent.querySelector('.todo-list__item-actions-icon.delete-list-icon').classList.toggle('todo-list__item-actions-icon_disable')
            currentParent.querySelector('.todo-list__item-actions-icon.edit-list-icon').classList.toggle('todo-list__item-actions-icon_disable')
        }
    }
}

// Open Comment

const infoBody = document.querySelectorAll('.review')
const modalWindow = document.querySelector('.review-modal')
const modalContainer = document.querySelector('.review-modal__container')

infoBody.forEach((item, index) => {
    if (item.children[1].textContent.length > 150) {
        item.children[1].setAttribute('title', item.children[1].textContent)
        item.children[1].textContent = item.children[1].textContent.slice(0, 149) + '...';
        let indexForMoved = -1

        item.addEventListener('click', (e) => {
            e.preventDefault();
            modalWindow.classList.toggle('displayShow');

            if (modalWindow.classList.contains('displayShow')){
                modalContainer.appendChild(item);
                item.children[1].textContent = item.children[1].getAttribute('title');
                indexForMoved = index
            }
            else{                
                item.children[1].textContent = item.children[1].textContent.slice(0, 149) + '...';
                infoBody[indexForMoved - 1].after(item);

            }
        })

        modalWindow.addEventListener('click', (e) => {

            if (modalWindow.classList.contains('displayShow')){
                modalWindow.classList.toggle('displayShow');
                item.children[1].textContent = item.children[1].textContent.slice(0, 149) + '...';
                infoBody[indexForMoved - 1].after(item);
            }
        })
    }
})



