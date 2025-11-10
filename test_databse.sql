CREATE TABLE Recettes (
    id_recette INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(255),
    instructions TEXT,
    type_recette VARCHAR(100),
    score REAL,
    note_base INT,
    image VARCHAR(255),
    difficulte VARCHAR(50)
);

CREATE TABLE Aliments (
    id_aliment INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255),
    categorie VARCHAR(100),
    nutriscore VARCHAR(10),
    image VARCHAR(255)
);

CREATE TABLE RecetteAliment (
    id_RecetteAliment INT AUTO_INCREMENT PRIMARY KEY,
    id_recette INT,
    id_aliment INT,
    quantite REAL,
    unite VARCHAR(50),
    remarque TEXT,
    FOREIGN KEY (id_recette) REFERENCES Recettes(id_recette),
    FOREIGN KEY (id_aliment) REFERENCES Aliments(id_aliment)
);

CREATE TABLE Profil (
    id_profil INT AUTO_INCREMENT PRIMARY KEY,
    poids REAL,
    taille REAL,
    objectif VARCHAR(255)
);

CREATE TABLE Frigo (
    id_frigo INT AUTO_INCREMENT PRIMARY KEY,
    id_aliment INT,
    quantite REAL,
    date_ajout DATE,
    date_peremption DATE,
    FOREIGN KEY (id_aliment) REFERENCES Aliments(id_aliment)
);

CREATE TABLE Historique (
    id_historique INT AUTO_INCREMENT PRIMARY KEY,
    id_recette INT,
    date_action DATETIME,
    duree_totale_min INT,
    FOREIGN KEY (id_recette) REFERENCES Recettes(id_recette)
);

CREATE TABLE FeedbackRecette (
    id_feedback INT AUTO_INCREMENT PRIMARY KEY,
    id_recette INT,
    favori INT,
    note INT,
    FOREIGN KEY (id_recette) REFERENCES Recettes(id_recette)
);

INSERT INTO Recettes (titre, instructions, type_recette, score, note_base, image, difficulte) VALUES
('No-Bake Nut Cookies', 'In a heavy saucepan, mix brown sugar, milk, vanilla, and butter. Bring to boil...', 'Dessert', 4.5, 10, 'https://loremflickr.com/320/240/cookie', 'Facile'),
('Jewell Ball''S Chicken', 'Place chipped beef on bottom of baking dish. Arrange chicken over beef...', 'Plat principal', 4.2, 8, 'https://loremflickr.com/320/240/chicken', 'Moyenne'),
('Creamy Corn', 'In a slow cooker, combine all ingredients. Cook until creamy...', 'Accompagnement', 4.6, 9, 'https://loremflickr.com/320/240/corn', 'Facile'),
('Chicken Funny', 'Boil and debone chicken. Mix with soup and serve hot...', 'Plat principal', 4.0, 7, 'https://loremflickr.com/320/240/chicken', 'Facile'),
('Reeses Cups (Candy)', 'Combine first four ingredients and press in pan...', 'Dessert', 4.8, 10, 'https://loremflickr.com/320/240/chocolate', 'Facile'),
('Quick Chili', 'Brown beef, add beans, tomato sauce, and chili powder...', 'Plat principal', 4.3, 9, 'https://loremflickr.com/320/240/chili', 'Moyenne'),
('Pineapple Pie', 'Mix pineapple, sugar, and eggs. Pour into crust and bake...', 'Dessert', 4.7, 9, 'https://loremflickr.com/320/240/pie', 'Moyenne'),
('Garlic Butter Shrimp', 'Sauté shrimp in garlic butter sauce for 5 minutes...', 'Plat principal', 4.9, 10, 'https://loremflickr.com/320/240/shrimp', 'Facile'),
('Vegetable Soup', 'Combine all vegetables, broth, and spices. Simmer for 30 minutes...', 'Soupe', 4.4, 8, 'https://loremflickr.com/320/240/soup', 'Facile'),
('Chocolate Mousse', 'Melt chocolate, mix with cream and eggs, chill 2 hours...', 'Dessert', 4.9, 10, 'https://loremflickr.com/320/240/mousse', 'Moyenne');


INSERT INTO Aliments (nom, categorie, nutriscore, image) VALUES
('brown sugar', 'sucre', 'D', 'https://loremflickr.com/320/240/sugar'),
('milk', 'produit laitier', 'B', 'https://loremflickr.com/320/240/milk'),
('vanilla', 'arôme', 'A', 'https://loremflickr.com/320/240/vanilla'),
('butter', 'matière grasse', 'C', 'https://loremflickr.com/320/240/butter'),
('chicken', 'viande', 'B', 'https://loremflickr.com/320/240/chicken'),
('corn', 'légume', 'A', 'https://loremflickr.com/320/240/corn'),
('peanut butter', 'fruit sec', 'B', 'https://loremflickr.com/320/240/peanutbutter'),
('beef', 'viande', 'C', 'https://loremflickr.com/320/240/beef'),
('pineapple', 'fruit', 'A', 'https://loremflickr.com/320/240/pineapple'),
('shrimp', 'fruit de mer', 'B', 'https://loremflickr.com/320/240/shrimp'),
('vegetables', 'légume', 'A', 'https://loremflickr.com/320/240/vegetable'),
('chocolate', 'sucre', 'E', 'https://loremflickr.com/320/240/chocolate');

INSERT INTO RecetteAliment (id_recette, id_aliment, quantite, unite, remarque) VALUES
(1, 1, 1.0, 'cup', 'firmly packed'),
(1, 2, 0.5, 'cup', 'evaporated'),
(1, 3, 1.0, 'tsp', ''),
(1, 4, 0.5, 'cup', 'melted'),
(2, 5, 4.0, 'pcs', 'boned and skinned'),
(2, 8, 1.0, 'jar', 'chipped beef'),
(3, 6, 16.0, 'oz', 'frozen'),
(3, 4, 1.0, 'tbsp', 'melted'),
(4, 5, 1.0, 'whole', ''),
(4, 3, 1.0, 'tsp', ''),
(5, 7, 1.0, 'cup', ''),
(5, 1, 0.75, 'cup', ''),
(5, 4, 0.5, 'cup', ''),
(6, 8, 500.0, 'g', ''),
(6, 11, 200.0, 'g', ''),
(6, 4, 1.0, 'tbsp', ''),
(7, 9, 1.0, 'cup', ''),
(7, 1, 0.5, 'cup', ''),
(7, 2, 0.25, 'cup', ''),
(8, 10, 200.0, 'g', ''),
(8, 4, 1.0, 'tbsp', ''),
(8, 3, 0.5, 'tsp', ''),
(9, 11, 300.0, 'g', ''),
(9, 2, 2.0, 'cup', ''),
(9, 4, 1.0, 'tbsp', ''),
(10, 12, 200.0, 'g', ''),
(10, 2, 1.0, 'cup', ''),
(10, 4, 1.0, 'tbsp', '');

