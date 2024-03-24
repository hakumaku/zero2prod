use secrecy::{ExposeSecret, Secret};

#[derive(serde::Deserialize)]
pub struct DatabaseSettings {
    pub username: String,
    pub password: Secret<String>,
    pub port: u16,
    pub host: String,
    pub database_name: String,
}

#[derive(serde::Deserialize)]
pub struct Settings {
    pub database: DatabaseSettings,
    pub application_port: u16,
}

impl DatabaseSettings {
    pub fn connection_string(&self) -> Secret<String> {
        Secret::new(format!(
            "postgres://{username}:{password}@{host}:{port}/{database_name}",
            username = self.username,
            password = self.password.expose_secret(),
            host = self.host,
            port = self.port,
            database_name = self.database_name,
        ))
    }
    pub fn connection_string_without_db(&self) -> Secret<String> {
        Secret::new(format!(
            "postgres://{username}:{password}@{host}:{port}",
            username = self.username,
            password = self.password.expose_secret(),
            host = self.host,
            port = self.port,
        ))
    }
}

pub fn get_configuration() -> Result<Settings, config::ConfigError> {
    let settings = config::Config::builder()
        .add_source(config::File::new(
            "configuration.yaml",
            config::FileFormat::Yaml,
        ))
        .build()?;

    settings.try_deserialize::<Settings>()
}
