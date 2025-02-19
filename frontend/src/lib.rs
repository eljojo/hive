mod components;
mod router;
mod stores;

use crate::components::organisms::navbar::Navbar;
use crate::router::{switch, Route};
use serde::{Deserialize, Serialize};
use yew::prelude::*;
use yew_router::prelude::*;

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct Gretting {
    en: String,
    de: String,
}

#[function_component(App)]
pub fn app() -> Html {
    html! {
    <div>
        <BrowserRouter>
            <Navbar />
            <Switch<Route> render={Switch::render(switch)} />
        </BrowserRouter>
    </div>
    }
}
