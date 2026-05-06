Setup Instructions
1️.Clone the repository
git clone https://github.com/11MK11/book_shop_docker.git
cd book_shop_docker

2️.Create .env file

Create a file named .env in the root directory and copy:

SECRET_KEY=your_secret_key_here
POSTGRES_DB=bookshop
POSTGRES_USER=bookshop_user
POSTGRES_PASSWORD=your_password_here
ALLOWED_HOSTS=localhost,127.0.0.1

3️.Run the application
docker compose up --build

4️.Open in browser
http://localhost:8000

Malek Al-Qurany 20210083
Hashem Al-Kilani 20210047