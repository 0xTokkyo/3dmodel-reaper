  
  // Extrait les models 3d des vaisseaux star citizen en téléchargant le liens du model
  // via l'api fleetyard/models/${slug}. Les slugs sont dans un fichier slugs.json qui
  // répertorie tout les vaisseaux star citizen disponnible possedant un model 3d

  // Derniere mise à jour : 04/01/2024

  const axios = require('axios');
  const fs = require('fs');
  const path = require('path');

  const fetchHoloUrl = async (apiUrl) => {
    try {
      const response = await axios.get(apiUrl);
      return { holoUrl: response.data.holo, modelName: path.basename(apiUrl) };
    } catch (error) {
      console.error(`Error fetching data from ${apiUrl}:`, error);
    }
  };

  const downloadFile = async (url, filename) => {
    try {
      const response = await axios.get(url, { responseType: 'stream' });
      const writer = fs.createWriteStream(filename);
      response.data.pipe(writer);
      return new Promise((resolve, reject) => {
        writer.on('finish', resolve);
        writer.on('error', reject);
      });
    } catch (error) {
      console.error(`Error downloading file from ${url}:`, error);
    }
  };

  const main = async () => {
    // Lire le fichier slugs.json et parser le contenu en tant qu'array
    const slugs = JSON.parse(fs.readFileSync('slugs.json', 'utf-8'));
  
    const downloadDir = path.join(__dirname, 'models');
    fs.mkdirSync(downloadDir, { recursive: true });
  
    for (const slug of slugs) { // Ici, slugs est déjà un array
      const apiUrl = `https://api.fleetyards.net/v1/models/${slug}/`;
      console.log(`Fetching data for ${slug} from ${apiUrl}`);
      try {
        const { holoUrl, modelName } = await fetchHoloUrl(apiUrl);
        console.log(`Downloading file from ${holoUrl}`);
        const filename = path.join(downloadDir, `${modelName}.gltf`);
        await downloadFile(holoUrl, filename);
      } catch (error) {
        console.error(`Error processing ${slug}:`, error);
      }
    }
  };

  main();