const firstPublish = [{
    id: 1,
    title: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Magni, perferendis?',
    order: 1
}]
const secondPublish = [{
    id: 2,
    title: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Magni, perferendis?',
    order: 3
}]
const thirdPublish = [{
    id: 3,
    title: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Magni, perferendis?',
    order: 5
}]
const fourthPublish = [{
    id: 4,
    title: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Magni, perferendis?',
    order: 2
}]
const fifthPublish = [{
    id: 5,
    title: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Magni, perferendis?',
    order: 4
}]


const publishMainParent = document.querySelector('.hp-publish__list');
const listPublishes = [firstPublish[0], 
                       secondPublish[0], 
                       thirdPublish[0], 
                       fourthPublish[0], 
                       fifthPublish[0]]

if (publishMainParent) {
    console.log('Publish_classwork:')
    console.log(listPublishes);
    listPublishes
        .sort((item1, item2) => item1.order - item2.order)        
        .forEach(item => {
            console.log(item);
            let publishItem = `
                <li class="hp-publish__list-item completed">`

            if (item.order % 2)
            {
                publishItem += `
                    <div class="hp-publish__list-item-text_hidden">${item.title}</div>
                    <div class="hp-publish__list-item-count">${item.order}</div>
                    <div class="hp-publish__list-item-text">${item.title}</div>`
            }
            else
            {
                publishItem += `
                    <div class="hp-publish__list-item-text">${item.title}</div>
                    <div class="hp-publish__list-item-count">${item.order}</div>
                    <div class="hp-publish__list-item-text_hidden">${item.title}</div>`
            }
                publishItem += `
                </li>`
            
            publishMainParent.insertAdjacentHTML('beforeend', publishItem)
        })
}