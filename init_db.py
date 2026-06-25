import sqlite3

# 1. sqlite3.connect('database.db')
conn = sqlite3.connect('database.db')

# 2. Print success message
print("Otwarto bazę danych pomyślnie")

# 3. Create table
conn.execute('''
CREATE TABLE IF NOT EXISTS books (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    title       TEXT NOT NULL,
    author      TEXT NOT NULL,
    description TEXT NOT NULL
);
''')

# 4. Print success message
print("Tabela utworzona pomyślnie")

# 5. Insert 9 book records
books = [
    ('Wiedźmin: Ostatnie życzenie', 'Andrzej Sapkowski', 'Zbiór opowiadań wprowadzający do świata wiedźmina Geralta z Rivii, pełen mrocznych baśni i potworów.'),
    ('Rok 1984', 'George Orwell', 'Klasyczna powieść dystopijna przedstawiająca totalitarny świat pod absolutną kontrolą Wielkiego Brata, gdzie prawda jest manipulowana.'),
    ('Podziemny krąg', 'Chuck Palahniuk', 'Psychologiczna powieść o bezimiennym narratorze cierpiącym na bezsenność, który wraz z charyzmatycznym Tylerem Durdenem zakłada sekretny klub walki.'),
    ('Nowy wspaniały świat', 'Aldous Huxley', 'Wizja przyszłości, w której społeczeństwo kontrolowane jest za pomocą zaawansowanej genetyki, konsumpcjonizmu i narkotyku o nazwie soma.'),
    ('Tako rzecze Zaratustra', 'Friedrich Nietzsche', 'Filozoficzne dzieło przedstawiające koncepcję nadczłowieka (Übermensch), śmierć Boga oraz ideę wiecznego powrotu.'),
    ('Poza dobrem i złem', 'Friedrich Nietzsche', 'Głęboka krytyka tradycyjnej moralności, dogmatów religijnych i fundamentów zachodniej filozofii, wprowadzająca pojęcie woli mocy.'),
    ('Świat jako wola i przedstawienie', 'Arthur Schopenhauer', 'Główne dzieło filozoficzne autora, wprowadzające pesymistyczną wizję rzeczywistości, którą rządzi ślepa, bezcelowa wola.'),
    ('Aforyzmy o mądrości życia', 'Arthur Schopenhauer', 'Zbiór esejów zawierających praktyczne porady dotyczące radzenia sobie z cierpieniem, samotnością i dążenia do wewnętrznego spokoju.'),
    ('Boska Komedia: Piekło', 'Dante Alighieri', 'Poemat epicki opisujący wędrówkę autora przez dziewięć kręgów piekielnych, gdzie potępieni ponoszą kary adekwatne do swoich grzechów.')
]

conn.executemany('INSERT INTO books (title, author, description) VALUES (?, ?, ?)', books)

# 6. Commit and close
conn.commit()
conn.close()

# 7. Print final success message
print("Książki zostały pomyślnie dodane do bazy danych!")
