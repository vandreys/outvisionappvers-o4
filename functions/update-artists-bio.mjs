import { readFileSync } from 'fs';
import { join } from 'path';
import { request } from 'https';
import os from 'os';

const cred = JSON.parse(readFileSync(join(process.env.APPDATA || join(os.homedir(), 'AppData', 'Roaming'), 'firebase', 'victorandrey02_gmail_com_application_default_credentials.json'), 'utf8'));

function getToken() {
  const body = new URLSearchParams({ client_id: cred.client_id, client_secret: cred.client_secret, refresh_token: cred.refresh_token, grant_type: 'refresh_token' }).toString();
  return new Promise((res, rej) => {
    const req = request({ hostname: 'oauth2.googleapis.com', path: '/token', method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }, r => {
      let d = ''; r.on('data', c => d += c); r.on('end', () => res(JSON.parse(d).access_token));
    });
    req.on('error', rej); req.write(body); req.end();
  });
}

function patchBio(token, docId, bio) {
  const body = JSON.stringify({
    fields: {
      bio: {
        mapValue: {
          fields: {
            pt: { stringValue: bio.pt },
            en: { stringValue: bio.en },
            es: { stringValue: bio.es }
          }
        }
      }
    }
  });
  return new Promise((res, rej) => {
    const path = `/v1/projects/outvision-app-24329/databases/(default)/documents/artists/${docId}?updateMask.fieldPaths=bio`;
    const req = request({ hostname: 'firestore.googleapis.com', path, method: 'PATCH', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token } }, r => {
      let d = ''; r.on('data', c => d += c); r.on('end', () => res(r.statusCode));
    });
    req.on('error', rej); req.write(body); req.end();
  });
}

const updates = [
  {
    id: '3gOQ0pUD0iVmDiQHzwVp',
    name: 'Iêda Jardim',
    bio: {
      pt: 'Iêda Jardim é artista visual com trajetória construída entre a cerâmica, a escultura, a gravura, desenho e a pintura, em uma pesquisa que aproxima matéria, gesto e memória. Sua obra nasce do contato direto com os materiais e se desenvolvem em formas que evocam corpos, casas e seres em estado de passagem, como se cada peça guardasse algo entre o abrigo e a transformação. Bacharel em Artes Plásticas pela Escola Guignard/ UEMG, especialista em escultura, cerâmica, serigrafia e xilogravura, Iêda desenvolveu um percurso marcado por exposições coletivas e individuais, prêmios e participações em mostras no Brasil e no exterior. Em sua pesquisa, o cotidiano se encontra com o simbólico, e a delicadeza convive com a força da ancestralidade. Seu trabalho dá forma a um universo sensível e próprio, no qual a matéria se torna presença e possibilidade de reinvenção.',
      en: "Iêda Jardim is a visual artist whose practice has been built across ceramics, sculpture, printmaking, drawing, and painting, in a body of work that brings together matter, gesture, and memory. Her work emerges from direct contact with materials and develops into forms that evoke bodies, houses, and beings in a state of passage, as if each piece held something between shelter and transformation. Holding a Bachelor's degree in Visual Arts from Escola Guignard/UEMG, with specializations in sculpture, ceramics, screen printing, and woodcut, Iêda has developed a trajectory marked by group and solo exhibitions, awards, and participation in shows in Brazil and abroad. In her research, the everyday meets the symbolic, and delicacy coexists with the force of ancestry. Her work gives form to a sensitive and singular universe in which matter becomes presence and the possibility of reinvention.",
      es: 'Iêda Jardim es artista visual con una trayectoria construida entre la cerámica, la escultura, el grabado, el dibujo y la pintura, en una investigación que aproxima materia, gesto y memoria. Su obra nace del contacto directo con los materiales y se desarrolla en formas que evocan cuerpos, casas y seres en estado de tránsito, como si cada pieza guardara algo entre el refugio y la transformación. Licenciada en Artes Plásticas por la Escola Guignard/UEMG, especialista en escultura, cerámica, serigrafía y xilografía, Iêda ha desarrollado una trayectoria marcada por exposiciones colectivas e individuales, premios y participaciones en muestras en Brasil y en el exterior. En su investigación, lo cotidiano se encuentra con lo simbólico, y la delicadeza convive con la fuerza de la ancestralidad. Su trabajo da forma a un universo sensible y propio, en el que la materia se convierte en presencia y posibilidad de reinvención.'
    }
  },
  {
    id: 'EAI3FcIGVDEfcMtIn6Ix',
    name: 'Jessie Kleemann',
    bio: {
      en: "Jessie Kleemann's practice is based on the complex relationships and exchanges between cultures; she explores the ways in which Greenlandic Inuit identity and tradition, the body, land, and language change over time. Her work is modelled on an expressive approach to video art, experimental theatre, feminism, the body, and performance art. She is a recent recipient of the Eckersberg Medal from the Royal Danish Academy of Fine Arts in recognition of her lifetime achievement as an artist, and her work has been widely exhibited across the globe.",
      pt: 'A prática de Jessie Kleemann baseia-se nas relações complexas e nas trocas entre culturas; ela explora as formas pelas quais a identidade e a tradição Inuit da Groenlândia, o corpo, a terra e a linguagem se transformam ao longo do tempo. Seu trabalho é moldado por uma abordagem expressiva da videoarte, do teatro experimental, do feminismo, do corpo e da performance. Ela é recente ganhadora da Medalha Eckersberg da Real Academia Dinamarquesa de Belas Artes, em reconhecimento à sua trajetória como artista, e seu trabalho tem sido amplamente exibido em todo o mundo.',
      es: 'La práctica de Jessie Kleemann se basa en las complejas relaciones e intercambios entre culturas; explora las formas en que la identidad y la tradición Inuit de Groenlandia, el cuerpo, la tierra y el lenguaje cambian con el tiempo. Su trabajo se modela en un enfoque expresivo del videoarte, el teatro experimental, el feminismo, el cuerpo y el performance. Es reciente ganadora de la Medalla Eckersberg de la Real Academia Danesa de Bellas Artes en reconocimiento a su trayectoria artística, y su obra ha sido ampliamente exhibida en todo el mundo.'
    }
  },
  {
    id: 'lxv9SVlRJY35HMzeDYMx',
    name: 'James Kudo',
    bio: {
      pt: 'Artista visual cuja prática investiga as relações entre memória, território e imagem. Graduado em design gráfico pela Faculdade de Belas Artes em 1989, morou em Nova Iorque de 1992 a 1994, estudou pintura abstrata na escola Art Student League orientado pelo professor e pintor Bruce Dorfman. Trabalhou como pattern designer no escritório de arquitetura Diamond & Baratta em Nova Iorque. O tema "topofilia" como partida inicial do seu trabalho é o terreno ampliado que enfatiza a especificidade dos recortes da memória especialmente relacionados à transformação da sua cidade natal, parcialmente demolida e inundada para a construção de uma usina hidrelétrica. O simulacro de colagens e imagens apropriadas de enciclopédias como também os moldes de vestuário, operam como dispositivos de construção para várias narrativas refletindo múltiplas camadas de experiências, subjetividade e deslocamento.',
      en: 'Visual artist whose practice investigates the relationships between memory, territory, and image. He graduated in graphic design from the Faculdade de Belas Artes in 1989, lived in New York from 1992 to 1994, and studied abstract painting at the Art Students League under professor and painter Bruce Dorfman. He worked as a pattern designer at the architecture firm Diamond & Baratta in New York. The theme of "topophilia" as the starting point for his work is an expanded terrain that emphasizes the specificity of memory fragments, particularly related to the transformation of his hometown, partially demolished and flooded for the construction of a hydroelectric plant. The simulacrum of collages and images appropriated from encyclopedias, as well as clothing patterns, operate as construction devices for various narratives reflecting multiple layers of experience, subjectivity, and displacement.',
      es: 'Artista visual cuya práctica investiga las relaciones entre memoria, territorio e imagen. Se graduó en diseño gráfico en la Faculdade de Belas Artes en 1989, vivió en Nueva York de 1992 a 1994 y estudió pintura abstracta en la Art Students League bajo la orientación del profesor y pintor Bruce Dorfman. Trabajó como diseñador de patrones en el estudio de arquitectura Diamond & Baratta en Nueva York. El tema de la "topofilia" como punto de partida de su trabajo es el terreno ampliado que enfatiza la especificidad de los recortes de la memoria, especialmente relacionados con la transformación de su ciudad natal, parcialmente demolida e inundada para la construcción de una central hidroeléctrica. El simulacro de collages e imágenes apropiadas de enciclopedias, así como los moldes de vestuario, operan como dispositivos de construcción para diversas narrativas que reflejan múltiples capas de experiencias, subjetividad y desplazamiento.'
    }
  },
  {
    id: 'nO2JiTS5X0k7m2pKEvZj',
    name: 'Evandro Soares',
    bio: {
      pt: 'Natural de Mundo Novo, Bahia, Evandro Soares vive e trabalha em Goiânia, Goiás, onde desenvolve uma prática artística ancorada em investigação contínua sobre espaço, matéria e forma. Sua pesquisa atravessa linguagens — escultura, pintura, desenho e instalação — não como escolhas isoladas, mas como ferramentas de um mesmo projeto poético em constante expansão. No centro de seu trabalho está uma inquietação sobre os limites do visível: como o vazio pode ser estrutura, como a sombra pode ser desenho, como o frágil pode ser arquitetura. Títulos como Arquiteturas Frágeis, Espaço Limítrofe e Metadesenhos revelam um artista que pensa a obra antes de fazê-la — e que faz da própria dúvida um método. Essa pesquisa ganha uma dimensão incomum ao incorporar engenhocas mecânicas e invenções próprias, aproximando arte e pensamento técnico num diálogo que escapa às categorias convencionais. O objeto não ilustra uma ideia — ele é a ideia em movimento.',
      en: 'Born in Mundo Novo, Bahia, Evandro Soares lives and works in Goiânia, Goiás, where he develops an artistic practice grounded in continuous investigation of space, matter, and form. His research moves across mediums — sculpture, painting, drawing, and installation — not as isolated choices, but as tools of a single poetic project in constant expansion. At the center of his work lies a preoccupation with the limits of the visible: how emptiness can be structure, how shadow can be drawing, how the fragile can be architecture. Titles such as Fragile Architectures, Liminal Space, and Metadrawings reveal an artist who thinks through the work before making it — and who turns doubt itself into a method. This research takes on an uncommon dimension by incorporating mechanical devices and his own inventions, bringing art and technical thinking into a dialogue that escapes conventional categories. The object does not illustrate an idea — it is the idea in motion.',
      es: 'Natural de Mundo Novo, Bahia, Evandro Soares vive y trabaja en Goiânia, Goiás, donde desarrolla una práctica artística anclada en la investigación continua sobre el espacio, la materia y la forma. Su investigación atraviesa lenguajes — escultura, pintura, dibujo e instalación — no como elecciones aisladas, sino como herramientas de un mismo proyecto poético en constante expansión. En el centro de su trabajo hay una inquietud sobre los límites de lo visible: cómo el vacío puede ser estructura, cómo la sombra puede ser dibujo, cómo lo frágil puede ser arquitectura. Títulos como Arquitecturas Frágiles, Espacio Limítrofe y Metadibujos revelan a un artista que piensa la obra antes de hacerla — y que convierte la propia duda en un método. Esta investigación adquiere una dimensión inusual al incorporar artilugios mecánicos e invenciones propias, aproximando el arte y el pensamiento técnico en un diálogo que escapa a las categorías convencionales. El objeto no ilustra una idea — es la idea en movimiento.'
    }
  }
];

const token = await getToken();
for (const artist of updates) {
  const status = await patchBio(token, artist.id, artist.bio);
  console.log(status === 200 ? `✓ ${artist.name}` : `✗ ${artist.name} — HTTP ${status}`);
}
console.log('\nPronto!');
process.exit(0);
