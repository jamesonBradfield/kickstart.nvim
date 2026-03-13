;; extends

; 1. Comment Blocks (The "Big Comment" fold)
(comment)+ @fold

; 2. Standard Code Blocks (Functions, Ifs, Loops)
(body) @fold

; 3. Setters & Getters (Specific to your tree dump!)
(set_body) @fold

; 4. Data Structures (Multi-line Arrays & Dictionaries)
(array) @fold
(dictionary) @fold

; 5. Match Statements (GDScript specific)
(match_body) @fold

; 6. Long Parameters/Arguments (Splitting functions across lines)
(parameters) @fold
(arguments) @fold
