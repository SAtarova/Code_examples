// const arr = [
//     {
//         id: 1,
//         title: 'some text',
//     },
//     {
//         id: 1,
//         title: 'some text',
//     },
//     {
//         id: 2,
//         title: 'some text',
//     }
// ]
// let newArr = arr.reduce((acc, item) => {
//     if(!acc.some(elem => elem.id === item.id)){
//         acc.push(item)
//     }
//     return acc;
// }, [])
// console.log(newArr);

/*
Обращение к элементу
*/

// const inputNewID = document.getElementById('input1')
// console.log(inputNewID);
// const inputNewClassName = document.getElementsByClassName('input-field')
// console.log(inputNewClassName);
// const inputTagName = document.getElementsByTagName('input')
// console.log(inputTagName);
// const inputName = document.getElementsByName('name')
// console.log(inputName);

// const inputIDNEW = document.querySelector('#input1')
// const inputClassNameNEW = document.querySelector('.input-field')
// const inputTagNameNEW = document.querySelector('input')
// const inputNameAttr = document.querySelector('input[name ="name"]')
// console.log(inputIDNEW);
// console.log(inputClassNameNEW);
// console.log(inputTagNameNEW);
// console.log(inputNameAttr);

// const inputClassNameNEWAll = [...document.querySelectorAll('.input-field')]
// const inputTagNameNEWAll = document.querySelectorAll('input')
// console.log(inputClassNameNEWAll);
// console.log(inputTagNameNEWAll);


// const linkSingle = document.querySelectorAll('.simple-list__link');
// linkSingle.forEach((item, index) => {
//     item.textContent = (index + 1) + ' ' + item.textContent;
//     console.log(item.textContent);
// })
// const liSingle = document.querySelector('.simple-list__item');
// console.log(linkSingle.textContent);
// console.log(linkSingle.innerHTML);

// console.log(liSingle.textContent);
// console.log(liSingle.innerHTML);

// const inputsList = document.querySelectorAll('.input-field')
// inputsList.forEach(item => {
//     console.log(item.name);
//     item.value = `${item.name} hello`
// })

// const textSimple = document.querySelectorAll('.simple-text')
// textSimple.forEach((item, index) => {
//     if(index % 2 === 0){
//         item.classList.add('text-agl')
//     }

    // item.classList.remove('simple-text')

    // item.classList.toggle('text-agl')

    // if(!item.classList.contains('text-agl')){
    //     item.classList.add('text-agl')
    // }else{
    //     item.classList.remove('text-agl')
    // }

// })


// const newDiv = document.createElement('p')
// newDiv.textContent = 'some text'
// newDiv.classList.add('new-elem')

// const parentDiv = document.querySelector('.actions')
// parentDiv.appendChild(newDiv)


// const newButton = `<button class="simple-action">Call Back</button>`;
// parentDiv.insertAdjacentHTML('beforebegin', newButton);
// parentDiv.insertAdjacentHTML('beforeend', newButton);
// parentDiv.insertAdjacentHTML('afterbegin', newButton);
// parentDiv.insertAdjacentHTML('afterend', newButton);


// const btns = document.querySelectorAll('.simple-action')
// btns.forEach((btnSingle, index) => {
//     btnSingle.addEventListener('click', () => {
//         document.querySelectorAll('.simple-text')[index].classList.toggle('text-agl')
//         console.log('some text');
//     })
// })

// document.querySelector('.simple-one').remove()

// My resolvings -----------------------

//const objUl = document.querySelector('ul')
//const dictLi = objUl.querySelectorAll('li')
//dictLi.forEach(item => console.log(item.textContent))

//const objP = document.querySelectorAll('p')
//objP.forEach(item => item.className = 'elite-text')
//console.log(objP)

//const objInput = document.querySelectorAll('input')
//objInput.forEach(item => console.log(item.name))

//const objButtons = document.querySelectorAll('button')
//objButtons.forEach((item, index) => {
    //if (index % 2 == 0) {
        //item.classList.add('btn_white')
    //}
//})

//const objP = document.querySelectorAll('p')
//objP.forEach((item, index) => {
    //if (index % 2 != 0) {
        //item.textContent = item.textContent.slice(0, 96)
        //item.className = 'newListText'
        //console.log(item.textContent.length)
    //}
//})

//const listElements = ['jsdfkkgv', 'ksdjonk', 'jodfogh', 'mclo']
//listElements.forEach((item, index) => {
    //item = (index + 1) + '. ' + item;
    //console.log(item);
//})

//const objButtons = document.querySelectorAll('button');
//objButtons.forEach(item => {
    //item.textContent = ''
    //let objElement = `<span>Call Back</span>`
    //item.insertAdjacentHTML('beforeend', objElement);
//})

//const objInputs = document.querySelectorAll('input');
//objInputs.forEach(item => {
  //  item.placeholder = `Please enter your ${item.name}`
//})

//const objButtons2 = document.querySelectorAll('button')
//objButtons2.forEach((item, index) => {
    //item.addEventListener('click', function () {
        //this.remove()
    //})
//})

//const buttonListParent = document.querySelector('.actions');
//let buttonItem = `<button class="simple-action click">Call Back</button>`
//buttonListParent.insertAdjacentHTML('beforeend', buttonItem)
//const objButtons3 = document.querySelector('.simple-action.click')
//objButtons3.addEventListener('click', function () {
    //console.log('click');
 //})


/*
const listElements       = document.querySelector('.simple-list');
const listParentElements = document.querySelector('.main.container');
listElements.remove()
let listElementsNew = `<ul class="simple-list"></ul>`
listParentElements.insertAdjacentHTML('afterBegin', listElementsNew)

listElementsNew       = document.querySelector('ul');
const listTexts = ['Home', 'Catalog', 'About us', 'Contacts', 'Review']
for (let i = 0; i < 5; i++){
    let listItem = `<li class="simple-list__item"><a href="#" class="simple-list__link">${listTexts[i]}</a></li>`
    listElementsNew.insertAdjacentHTML('beforeend', listItem)
}
*/

class Strikethrough{

    buttonNew(){
        const buttonListParent = document.querySelector('.actions');
        let buttonItem = `<button class="simple-action click">Call Back</button>`
        buttonListParent.insertAdjacentHTML('beforeend', buttonItem)
    }

    buttonClick() {
        const objButton = document.querySelector('.simple-action.click')
        objButton.addEventListener('click', function (){
            let listElements   = document.querySelector('ul');
            let listLiElements = document.querySelectorAll('a');
            console.log(listLiElements);
            listLiElements.forEach((item, index) => {
                if (index % 2 != 0) {
                   //style.textDecoration
                  //item.setAttribute('text-decoration::after', 'line-through')
                  item.classList.add("line_through")
                }
            })
        })
    }
}
let objStrikethrough = new Strikethrough()
objStrikethrough.buttonNew()
objStrikethrough.buttonClick()


const buttonListParent = document.querySelector('.actions');
let buttonItem1 = `<button class="simple-action placehold">Input</button>`
buttonListParent.insertAdjacentHTML('beforeend', buttonItem1)
const objButton3 = document.querySelector('.simple-action.placehold')
objButton3.addEventListener('click', function (){
    let listLiElementsInput = document.querySelectorAll('input');
    listLiElementsInput.forEach(item => {
        item.setAttribute('value', item.placeholder)
    })
})

