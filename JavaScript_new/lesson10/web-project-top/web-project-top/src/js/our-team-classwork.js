const ourTeamList =[
    {
        id: 1,
        name: 'Seversky Nikita Viktorovich',
        role: 'editor',
        rating: 3.4,
        img: {
            src: './images/home-page/team/team-001.jpg',
            alt: 'Our main editor Seversky Nikita Viktorovich'
        }
    },
    {
        id: 2,
        name: 'Andrushina Lina Sergeevna',
        role: 'paper reader',
        rating: 2.3,
        img: {
            src: './images/home-page/team/team-002.jpeg',
            alt: 'Our main paper reader Andrushina Lina Sergeevna'
        }
    },
    {
        id: 3,
        name: 'Demidova Victoria Adamovna',
        role: 'tester',
        rating: 4.5,
        img: {
            src: './images/home-page/team/team-003.jpeg',
            alt: 'Our main tester Demidova Victoria Adamovna'
        }
    },
    {
        id: 4,
        name: 'Sokolov David Filippovich',
        role: 'editor',
        rating: 4.1,
        img: {
            src: './images/home-page/team/team-004.png',
            alt: 'Our main editor Sokolov David Filippovich'
        }
    },
    {
        id: 5,
        name: 'Mironov Danila Artemyevich',
        role: 'tester',
        rating: 3.8,
        img: {
            src: './images/home-page/team/team-005.png',
            alt: 'Our main editor Mironov Danila Artemyevich'
        }
    },
    {
        id: 6,
        name: 'Shulgin Alexander Vladimirovich',
        role: 'editor',
        rating: 5,
        img: {
            src: './images/home-page/team/team-006.jpeg',
            alt: 'Our main editor Shulgin Alexander Vladimirovich'
        }
    },
    {
        id: 7,
        name: 'Demina Miya Adamovna',
        role: 'paper reader',
        rating: 3.1,
        img: {
            src: './images/home-page/team/team-007.jpeg',
            alt: 'Our main paper reader Demina Miya Adamovna'
        }
    },
    {
        id: 8,
        name: 'Petrov Yaroslav Alexandrovich',
        role: 'editor',
        rating: 4.9,
        img: {
            src: './images/home-page/team/team-008.jpeg',
            alt: 'Our main editor Petrov Yaroslav Alexandrovich'
        }
    }
]

const teamMainParent = document.querySelector('.hp-team__cards'); //родитель
if(teamMainParent){
    ourTeamList
        .sort((a,b) => a.name > b.name ? 1 : -1)
        .forEach(item => {
            let currentTeam = `
            <li class="hp-team__card">
                <div class="
                    hp-team__card-img-wrapper
                    ${item.rating >= 4.5 ? 'hp-team__card-img-wrapper_gold' : null}
                "> 
                    <img src=${item.img.src} alt=${item.img.alt} loading="lazy" class="hp-team__card-img"> 
                </div>
                <p class="hp-team__card-trade">${item.role}</p>
                <p class="hp-team__card-name">${item.name}</p>
                <span 
                class="
                    hp-team__card-rating 
                    ${item.rating >= 4.5 ? 'hp-team__card-rating_gold' : null}
                ">
                    ${item.rating >= 4.5 ? 'Gold Rating' : 'Rating'}: 
                    ${item.rating}
                </span>
            </li>
            `;
            teamMainParent.insertAdjacentHTML('beforeend', currentTeam)
        })
}