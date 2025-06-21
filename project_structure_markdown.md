# 📁 Estructura del Proyecto Frontend

## 🌐 FRONTEND - Estructura Completa

```
FRONTEND/
├── 📄 vite.config.js                    # Configuración Vite
├── 📄 package.json                      # Dependencias Node.js
├── 📄 package-lock.json                 # Lock de dependencias
├── 📄 .env                              # Variables de entorno
├── 📄 .gitignore                        # Archivos ignorados por Git
├── 📄 README.md                         # Documentación del proyecto
├── 📄 index.html                        # Punto de entrada HTML
├── 📄 netlify.toml                      # Configuración Netlify
├── 📄 .prettierrc                       # Configuración Prettier
├── 📄 .eslintrc.js                      # Configuración ESLint
├── 📄 App.css                           # Estilos globales
├── 📄 App.jsx                           # Componente principal
├── 📄 index.css                         # Estilos base
├── 📄 main.jsx                          # Punto de entrada React
├── 📁 public/                           # Archivos públicos
│   ├── 📄 logoicon.svg                  # Logo de la aplicación
│   └── 📄 react.svg                     # Logo React
├── 📁 node_modules/                     # Dependencias instaladas
├── 📁 src/                              # Código fuente principal
│   ├── 📁 _mockApis/                    # APIs simuladas
│   │   ├── 📁 blog/                     # Mock datos blog
│   │   │   ├── 📄 BlogData.js
│   │   │   └── 📄 index.js
│   │   ├── 📁 chat/                     # Mock datos chat
│   │   │   └── 📄 ChatData.js
│   │   ├── 📁 contacts/                 # Mock datos contactos
│   │   │   └── 📄 ContactsData.js
│   │   ├── 📁 ecommerce/                # Mock datos ecommerce
│   │   │   └── 📄 ProductsData.js
│   │   ├── 📁 email/                    # Mock datos email
│   │   │   └── 📄 EmailData.js
│   │   ├── 📁 language/                 # Mock datos idiomas
│   │   │   └── 📄 LanguageData.js
│   │   ├── 📁 notes/                    # Mock datos notas
│   │   │   └── 📄 NotesData.js
│   │   ├── 📁 ticket/                   # Mock datos tickets
│   │   │   └── 📄 TicketData.js
│   │   └── 📁 userprofile/              # Mock datos perfiles
│   │       ├── 📄 PostData.js
│   │       └── 📄 UsersData.js
│   │
│   ├── 📁 assets/                       # Recursos estáticos
│   │   └── 📁 images/                   # Imágenes del proyecto
│   │       ├── 📁 backgrounds/          # Fondos e imágenes de fondo
│   │       │   ├── 📄 bronze.png
│   │       │   ├── 📄 gold.png
│   │       │   ├── 📄 silver.png
│   │       │   ├── 📄 piggy.png
│   │       │   ├── 📄 profilebg.jpg
│   │       │   ├── 📄 track-bg.png
│   │       │   ├── 📄 unlimited-bg.png
│   │       │   ├── 📄 website-under-construction.gif
│   │       │   ├── 📄 welcome-bg2.png
│   │       │   ├── 📄 errorimg.svg       # ⭐ Imagen de error
│   │       │   ├── 📄 login-bg.svg       # ⭐ Fondo login
│   │       │   ├── 📄 maintenance.svg    # ⭐ Mantenimiento
│   │       │   ├── 📄 maintenance2.svg
│   │       │   └── 📄 welcome-bg.svg     # ⭐ Bienvenida
│   │       ├── 📁 blog/                 # Imágenes del blog
│   │       │   ├── 📄 blog-img1.jpg
│   │       │   ├── 📄 blog-img2.jpg
│   │       │   ├── 📄 blog-img3.jpg
│   │       │   ├── 📄 blog-img4.jpg
│   │       │   ├── 📄 blog-img5.jpg
│   │       │   ├── 📄 blog-img6.jpg
│   │       │   ├── 📄 blog-img7.jpg
│   │       │   ├── 📄 blog-img8.jpg
│   │       │   ├── 📄 blog-img9.jpg
│   │       │   ├── 📄 blog-img10.jpg
│   │       │   └── 📄 blog-img11.jpg
│   │       ├── 📁 breadcrumb/           # Migas de pan
│   │       │   ├── 📄 ChatBg.png
│   │       │   └── 📄 emailSv.png
│   │       ├── 📁 chat/                 # Iconos chat
│   │       │   ├── 📄 icon-adobe.svg
│   │       │   ├── 📄 icon-chrome.svg
│   │       │   ├── 📄 icon-figma.svg
│   │       │   ├── 📄 icon-javascript.svg
│   │       │   └── 📄 icon-zip-folder.svg
│   │       ├── 📁 flag/                 # Banderas países
│   │       │   ├── 📄 icon-flag-cn.svg
│   │       │   ├── 📄 icon-flag-en.svg
│   │       │   ├── 📄 icon-flag-fr.svg
│   │       │   ├── 📄 icon-flag-sa.svg
│   │       │   └── 📄 icon-flag-vn.svg
│   │       ├── 📁 landingpage/          # Landing page
│   │       │   ├── 📁 apps/             # Screenshots apps
│   │       │   │   ├── 📄 app-blog-detail.jpg
│   │       │   │   ├── 📄 app-blog.jpg
│   │       │   │   ├── 📄 app-calendar.jpg
│   │       │   │   ├── 📄 app-chat.jpg
│   │       │   │   ├── 📄 app-contact.jpg
│   │       │   │   ├── 📄 app-ecommerce-checkout.jpg
│   │       │   │   ├── 📄 app-ecommerce-detail.jpg
│   │       │   │   ├── 📄 app-ecommerce-list.jpg
│   │       │   │   ├── 📄 app-ecommerce-shop.jpg
│   │       │   │   ├── 📄 app-email.jpg
│   │       │   │   ├── 📄 app-note.jpg
│   │       │   │   ├── 📄 app-ticket.jpg
│   │       │   │   └── 📄 app-user-profile.jpg
│   │       │   ├── 📁 background/       # Fondos landing
│   │       │   │   ├── 📄 c2a.png
│   │       │   │   └── 📄 slider-group.png
│   │       │   ├── 📁 demos/            # Screenshots demos
│   │       │   │   ├── 📄 demo-dark.jpg
│   │       │   │   ├── 📄 demo-firebase.jpg
│   │       │   │   ├── 📄 demo-horizontal.jpg
│   │       │   │   ├── 📄 demo-main.jpg
│   │       │   │   └── 📄 demo-rtl.jpg
│   │       │   ├── 📁 frameworks/       # Logos frameworks
│   │       │   │   ├── 📄 logo-apex.svg
│   │       │   │   ├── 📄 logo-figma.svg
│   │       │   │   ├── 📄 logo-js.svg
│   │       │   │   ├── 📄 logo-mui.svg
│   │       │   │   ├── 📄 logo-react.svg
│   │       │   │   ├── 📄 logo-redux.svg
│   │       │   │   └── 📄 logo-ts.svg
│   │       │   ├── 📁 profile/          # Imágenes perfil
│   │       │   │   ├── 📄 testimonial1.png
│   │       │   │   ├── 📄 testimonial2.png
│   │       │   │   ├── 📄 testimonial3.png
│   │       │   │   ├── 📄 user1.png
│   │       │   │   ├── 📄 user2.png
│   │       │   │   ├── 📄 user3.png
│   │       │   │   ├── 📄 user4.png
│   │       │   │   ├── 📄 user5.png
│   │       │   │   ├── 📄 user6.png
│   │       │   │   ├── 📄 user7.png
│   │       │   │   ├── 📄 user8.png
│   │       │   │   ├── 📄 user9.png
│   │       │   │   └── 📄 user-10.jpg
│   │       │   └── 📁 shape/            # Elementos gráficos
│   │       │       ├── 📄 badge.png
│   │       │       ├── 📄 badge.svg
│   │       │       ├── 📄 line-bg2.svg
│   │       │       ├── 📄 line-bg.svg
│   │       │       ├── 📄 shape-1.svg
│   │       │       ├── 📄 shape-2.svg
│   │       │       ├── 📄 bannering1.svg
│   │       │       ├── 📄 bannering2.svg
│   │       │       └── 📄 favicon.png
│   │       ├── 📁 logos/                # Logos aplicación
│   │       │   ├── 📄 dark-logo.svg
│   │       │   ├── 📄 favicon.ico
│   │       │   └── 📄 light-logo.svg
│   │       ├── 📁 products/             # Imágenes productos
│   │       │   ├── 📄 empty-shopping-bag2.gif
│   │       │   ├── 📄 payment-complete.gif
│   │       │   ├── 📄 payment.svg
│   │       │   ├── 📄 s1.jpg
│   │       │   ├── 📄 s2.jpg
│   │       │   ├── 📄 s3.jpg
│   │       │   ├── 📄 s4.jpg
│   │       │   ├── 📄 s5.jpg
│   │       │   ├── 📄 s6.jpg
│   │       │   ├── 📄 s7.jpg
│   │       │   ├── 📄 s8.jpg
│   │       │   ├── 📄 s9.jpg
│   │       │   ├── 📄 s10.jpg
│   │       │   ├── 📄 s11.jpg
│   │       │   └── 📄 s12.jpg
│   │       └── 📁 svgs/                 # Iconos SVG
│   │           └── 📄 react.svg
│   │
│   ├── 📁 components/                   # Componentes React
│   │   ├── 📁 apps/                     # Aplicaciones principales
│   │   │   ├── 📁 blog/                 # Sistema de blog
│   │   │   │   └── 📁 detail/           # Detalle del blog
│   │   │   │       ├── 📄 BlogComment.js    # ⭐ Comentarios
│   │   │   │       ├── 📄 BlogDetails.js    # ⭐ Detalles entrada
│   │   │   │       ├── 📄 BlogCard.js       # ⭐ Tarjeta blog
│   │   │   │       ├── 📄 BlogFeaturedCard.js
│   │   │   │       └── 📄 BlogListing.js    # ⭐ Lista blogs
│   │   │   ├── 📁 chats/                # Sistema de chat
│   │   │   │   ├── 📄 ChatContent.js        # ⭐ Contenido chat
│   │   │   │   ├── 📄 ChatInsideSidebar.js  # ⭐ Sidebar chat
│   │   │   │   ├── 📄 ChatListing.js        # ⭐ Lista chats
│   │   │   │   ├── 📄 ChatMsgSent.js
│   │   │   │   └── 📄 ChatSidebar.js
│   │   │   ├── 📁 contacts/             # Gestión contactos
│   │   │   │   ├── 📄 ContactAdd.js         # ⭐ Añadir contacto
│   │   │   │   ├── 📄 ContactDetails.js     # ⭐ Detalles contacto
│   │   │   │   ├── 📄 ContactFilter.js
│   │   │   │   ├── 📄 ContactList.js
│   │   │   │   ├── 📄 ContactListItem.js
│   │   │   │   └── 📄 ContactSearch.js      # ⭐ Búsqueda
│   │   │   ├── 📁 ecommerce/            # Sistema ecommerce
│   │   │   │   ├── 📁 productCart/      # Carrito compras
│   │   │   │   │   ├── 📄 AddToCart.js      # ⭐ Añadir carrito
│   │   │   │   │   └── 📄 AlertCart.js      # ⭐ Alertas carrito
│   │   │   │   ├── 📁 productCheckout/  # Checkout proceso
│   │   │   │   │   ├── 📄 FinalStep.js      # ⭐ Paso final
│   │   │   │   │   ├── 📄 FirstStep.js      # ⭐ Primer paso
│   │   │   │   │   ├── 📄 HorizontalStepper.js
│   │   │   │   │   ├── 📄 ProductCheckout.js
│   │   │   │   │   ├── 📄 SecondStep.js
│   │   │   │   │   └── 📄 ThirdStep.js      # ⭐ Tercer paso
│   │   │   │   ├── 📁 productDetail/    # Detalle producto
│   │   │   │   │   ├── 📄 Carousel.css
│   │   │   │   │   ├── 📄 ProductCarousel.js # ⭐ Carrusel
│   │   │   │   │   ├── 📄 ProductDesc.js     # ⭐ Descripción
│   │   │   │   │   ├── 📄 ProductDetail.js
│   │   │   │   │   ├── 📄 ProductRelated.js  # ⭐ Relacionados
│   │   │   │   │   └── 📄 SliderData.js
│   │   │   │   ├── 📁 productGrid/      # Grilla productos
│   │   │   │   │   ├── 📄 ProductFilter.js   # ⭐ Filtros
│   │   │   │   │   ├── 📄 ProductList.js     # ⭐ Lista productos
│   │   │   │   │   ├── 📄 ProductSearch.js   # ⭐ Búsqueda
│   │   │   │   │   └── 📄 ProductSidebar.js  # ⭐ Sidebar
│   │   │   │   └── 📁 productTableList/ # Tabla productos
│   │   │   │       └── 📄 ProductTableList.js
│   │   │   ├── 📁 email/                # Sistema email
│   │   │   │   ├── 📄 EmailActions.js       # ⭐ Acciones email
│   │   │   │   ├── 📄 EmailCompose.js       # ⭐ Redactar
│   │   │   │   ├── 📄 EmailContent.js       # ⭐ Contenido
│   │   │   │   ├── 📄 EmailFilter.js
│   │   │   │   ├── 📄 EmailList.js
│   │   │   │   ├── 📄 EmailListItem.js
│   │   │   │   └── 📄 EmailSearch.js        # ⭐ Búsqueda
│   │   │   ├── 📁 notes/                # Sistema notas
│   │   │   │   ├── 📄 AddNotes.js           # ⭐ Añadir nota
│   │   │   │   ├── 📄 NoteContent.js        # ⭐ Contenido nota
│   │   │   │   ├── 📄 NoteList.js
│   │   │   │   └── 📄 NoteSidebar.js        # ⭐ Sidebar notas
│   │   │   ├── 📁 tickets/              # Sistema tickets
│   │   │   │   ├── 📄 TicketFilter.js       # ⭐ Filtro tickets
│   │   │   │   └── 📄 TicketListing.js      # ⭐ Lista tickets
│   │   │   └── 📁 userprofile/          # Perfil usuario
│   │   │       ├── 📁 followers/        # Seguidores
│   │   │       │   └── 📄 FollowerCard.js   # ⭐ Tarjeta seguidor
│   │   │       ├── 📁 friends/          # Amigos
│   │   │       │   └── 📄 FriendsCard.js    # ⭐ Tarjeta amigo
│   │   │       ├── 📁 gallery/          # Galería
│   │   │       │   └── 📄 GalleryCard.js    # ⭐ Tarjeta galería
│   │   │       └── 📁 profile/          # Perfil
│   │   │           ├── 📄 IntroCard.js      # ⭐ Intro
│   │   │           ├── 📄 PhotosCard.js     # ⭐ Fotos
│   │   │           ├── 📄 Post.js           # ⭐ Post
│   │   │           ├── 📄 PostComments.js   # ⭐ Comentarios
│   │   │           ├── 📄 PostItem.js
│   │   │           ├── 📄 PostTextBox.js
│   │   │           ├── 📄 ProfileBanner.js  # ⭐ Banner perfil
│   │   │           └── 📄 ProfileTab.js     # ⭐ Tabs perfil
│   │   ├── 📁 container/                # Contenedores
│   │   │   └── 📄 PageContainer.js          # ⭐ Container página
│   │   ├── 📁 custom-scroll/            # Scroll personalizado
│   │   │   └── 📄 Scrollbar.js
│   │   └── 📁 dashboards/               # Dashboards
│   │       ├── 📁 ecommerce/            # Dashboard ecommerce
│   │       │   ├── 📄 Expence.js
│   │       │   ├── 📄 Growth.js
│   │       │   ├── 📄 MonthlyEarnings.js
│   │       │   ├── 📄 PaymentGateways.js
│   │       │   ├── 📄 ProductPerformances.js
│   │       │   ├── 📄 RecentTransactions.js
│   │       │   ├── 📄 RevenueUpdates.js
│   │       │   ├── 📄 Sales.js
│   │       │   ├── 📄 SalesOverview.js
│   │       │   ├── 📄 SalesTwo.js
│   │       │   ├── 📄 TotalEarnings.js
│   │       │   ├── 📄 WelcomeCard.js
│   │       │   └── 📄 YearlySales.js
│   │       └── 📁 modern/               # Dashboard moderno
│   │           ├── 📄 Customers.js
│   │           ├── 📄 EmployeesSalary.js
│   │           ├── 📄 MonthlyEarnings.js
│   │           ├── 📄 Projects.js
│   │           ├── 📄 RevenueUpdates.js
│   │           ├── 📄 SellingProducts.js
│   │           ├── 📄 Social.js
│   │           ├── 📄 TopCards.js
│   │           ├── 📄 TopPerformData.js
│   │           ├── 📄 TopPerformers.js
│   │           ├── 📄 WeeklyStats.js
│   │           └── 📄 YearlyBreakup.js
│   │
│   ├── 📁 forms/                        # Componentes formularios
│   │   ├── 📁 form-elements/            # Elementos formulario
│   │   │   ├── 📁 autoComplete/         # Autocompletado
│   │   │   │   ├── 📄 CheckboxesAutocomplete.js
│   │   │   │   ├── 📄 ComboBoxAutocomplete.js
│   │   │   │   ├── 📄 ControlledStateAutocomplete.js
│   │   │   │   ├── 📄 countrydata.js
│   │   │   │   ├── 📄 CountrySelectAutocomplete.js
│   │   │   │   ├── 📄 data.js
│   │   │   │   ├── 📄 FreeSoloAutocomplete.js
│   │   │   │   ├── 📄 MultipleValuesAutocomplete.js
│   │   │   │   └── 📄 SizesAutocomplete.js
│   │   │   ├── 📁 button/               # Botones
│   │   │   │   ├── 📄 ColorButtonGroup.js
│   │   │   │   ├── 📄 ColorButtons.js
│   │   │   │   ├── 📄 DefaultButtonGroup.js
│   │   │   │   ├── 📄 DefaultButtons.js
│   │   │   │   ├── 📄 FabColorButtons.js
│   │   │   │   ├── 📄 FabDefaultButton.js
│   │   │   │   ├── 📄 FabSizeButtons.js
│   │   │   │   ├── 📄 IconColorButtons.js
│   │   │   │   ├── 📄 IconLoadingButtons.js
│   │   │   │   ├── 📄 IconSizeButtons.js
│   │   │   │   ├── 📄 OutlinedColorButtons.js
│   │   │   │   ├── 📄 OutlinedDefaultButtons.js
│   │   │   │   ├── 📄 OutlinedIconButtons.js
│   │   │   │   ├── 📄 OutlinedSizeButtons.js
│   │   │   │   ├── 📄 SizeButton.js
│   │   │   │   ├── 📄 SizeButtonGroup.js
│   │   │   │   ├── 📄 TextButtonGroup.js
│   │   │   │   ├── 📄 TextColorButtons.js
│   │   │   │   ├── 📄 TextDefaultButtons.js
│   │   │   │   ├── 📄 TextIconButtons.js
│   │   │   │   ├── 📄 TextSizeButton.js
│   │   │   │   └── 📄 VerticalButtonGroup.js
│   │   │   ├── 📁 checkbox/             # Checkboxes
│   │   │   │   ├── 📄 Colors.js
│   │   │   │   ├── 📄 Custom.js
│   │   │   │   ├── 📄 Default.js
│   │   │   │   ├── 📄 DefaultColors.js
│   │   │   │   ├── 📄 Position.js
│   │   │   │   └── 📄 Sizes.js
│   │   │   ├── 📁 radio/                # Radio buttons
│   │   │   │   ├── 📄 ColorLabel.js
│   │   │   │   ├── 📄 Colors.js
│   │   │   │   ├── 📄 Custom.js
│   │   │   │   ├── 📄 Default.js
│   │   │   │   ├── 📄 Position.js
│   │   │   │   └── 📄 Sizes.js
│   │   │   └── 📁 switch/               # Switches
│   │   │       ├── 📄 Colors.js
│   │   │       ├── 📄 Custom.js
│   │   │       ├── 📄 Default.js
│   │   │       ├── 📄 DefaultLabel.js
│   │   │       ├── 📄 Position.js
│   │   │       └── 📄 Sizes.js
│   │   ├── 📁 form-horizontal/          # Formularios horizontales
│   │   │   ├── 📄 BasicIcons.js
│   │   │   ├── 📄 BasicLayout.js
│   │   │   ├── 📄 CollapsibleForm.js
│   │   │   ├── 📄 FormLabelAlignment.js
│   │   │   ├── 📄 FormSeparator.js
│   │   │   └── 📄 FormTabs.js
│   │   ├── 📁 form-layouts/             # Layouts formularios
│   │   │   ├── 📄 FbBasicHeaderForm.js
│   │   │   ├── 📄 FbDefaultForm.js
│   │   │   ├── 📄 FbDisabledForm.js
│   │   │   ├── 📄 FbInputVariants.js
│   │   │   ├── 📄 FbLeftIconForm.js
│   │   │   ├── 📄 FbOrdinaryForm.js
│   │   │   ├── 📄 FbReadonlyForm.js
│   │   │   ├── 📄 FbRightIconForm.js
│   │   │   └── 📄 index.js
│   │   ├── 📁 form-validation/          # Validación formularios
│   │   │   ├── 📄 FVCheckbox.js
│   │   │   ├── 📄 FVLogin.js
│   │   │   ├── 📄 FVOnLeave.js
│   │   │   ├── 📄 FVRadio.js
│   │   │   ├── 📄 FVRegister.js
│   │   │   └── 📄 FVSelect.js
│   │   └── 📁 form-vertical/            # Formularios verticales
│   │       ├── 📄 BasicIcons.js
│   │       ├── 📄 BasicLayout.js
│   │       ├── 📄 CollapsibleForm.js
│   │       ├── 📄 FormSeparator.js
│   │       └── 📄 FormTabs.js
│   │
│   ├── 📁 theme-elements/               # Elementos temáticos
│   │   ├── 📄 CustomCheckbox.js         # ⭐ Checkbox personalizado
│   │   ├── 📄 CustomDisabledButton.js   # ⭐ Botón deshabilitado
│   │   ├── 📄 CustomFormLabel.js        # ⭐ Label personalizado
│   │   ├── 📄 CustomOutlinedButton.js   # ⭐ Botón outlined
│   │   ├── 📄 CustomOutlinedInput.js    # ⭐ Input outlined
│   │   ├── 📄 CustomRadio.js            # ⭐ Radio personalizado
│   │   ├── 📄 CustomRangeSlider.js      # ⭐ Slider rango
│   │   ├── 📄 CustomSelect.js           # ⭐ Select personalizado
│   │   ├── 📄 CustomSlider.js           # ⭐ Slider personalizado
│   │   ├── 📄 CustomSocialButton.js     # ⭐ Botón social
│   │   ├── 📄 CustomSwitch.js           # ⭐ Switch personalizado
│   │   └── 📄 CustomTextField.js        # ⭐ TextField personalizado
│   │
│   ├── 📁 landingpage/                  # Página de inicio
│   │   ├── 📁 animation/                # Animaciones
│   │   │   └── 📄 Animation.js
│   │   ├── 📁 banner/                   # Banner principal
│   │   │   ├── 📄 Banner.js             # ⭐ Banner principal
│   │   │   └── 📄 BannerContent.js      # ⭐ Contenido banner
│   │   ├── 📁 c2a/                      # Call to Action
│   │   │   ├── 📄 C2a.js
│   │   │   ├── 📄 C2a2.js
│   │   │   └── 📄 GuaranteeCard.js
│   │   ├── 📁 demo-slider/              # Slider demos
│   │   │   ├── 📄 demo-slider.css
│   │   │   ├── 📄 DemoSlider.js
│   │   │   └── 📄 DemoTitle.js
│   │   ├── 📁 features/                 # Características
│   │   │   ├── 📄 Features.js
│   │   │   └── 📄 FeatureTitle.js
│   │   ├── 📁 footer/                   # Pie de página
│   │   │   └── 📄 Footer.js
│   │   ├── 📁 frameworks/               # Marcos de trabajo
│   │   │   ├── 📄 Frameworks.js
│   │   │   └── 📄 FrameworksTitle.js
│   │   ├── 📁 header/                   # Cabecera
│   │   │   ├── 📄 DemosDD.js
│   │   │   ├── 📄 Header.js             # ⭐ Header principal
│   │   │   ├── 📄 MobileSidebar.js
│   │   │   └── 📄 Navigations.js
│   │   └── 📁 testimonial/              # Testimonios
│   │       ├── 📄 testimonial.css
│   │       ├── 📄 Testimonial.js
│   │       └── 📄 TestimonialTitle.js
│   │
│   ├── 📁 material-ui/                  # Componentes Material-UI
│   │   ├── 📁 dialog/                   # Diálogos
│   │   │   ├── 📄 AlertDialog.js
│   │   │   ├── 📄 FormDialog.js
│   │   │   ├── 📄 FullscreenDialog.js
│   │   │   ├── 📄 MaxWidthDialog.js
│   │   │   ├── 📄 ResponsiveDialog.js
│   │   │   ├── 📄 ScrollContentDialog.js
│   │   │   ├── 📄 SimpleDialog.js
│   │   │   └── 📄 TransitionDialog.js
│   │   ├── 📁 lists/                    # Listas
│   │   │   ├── 📄 ControlsList.js
│   │   │   ├── 📄 FolderList.js
│   │   │   ├── 📄 NestedList.js
│   │   │   ├── 📄 SelectedList.js
│   │   │   ├── 📄 SimpleList.js
│   │   │   └── 📄 SwitchList.js
│   │   ├── 📁 popover/                  # Popovers
│   │   │   ├── 📄 ClickPopover.js
│   │   │   └── 📄 HoverPopover.js
│   │   └── 📁 transfer-list/            # Lista transferencia
│   │       ├── 📄 BasicTransferList.js
│   │       └── 📄 EnhancedTransferList.js
│   │
│   ├── 📁 pages/                        # Páginas principales
│   │   ├── 📁 account-setting/          # Configuración cuenta
│   │   │   ├── 📄 AccountTab.js
│   │   │   ├── 📄 BillsTab.js
│   │   │   ├── 📄 NotificationTab.js
│   │   │   └── 📄 SecurityTab.js
│   │   ├── 📁 faq/                      # Preguntas frecuentes
│   │   │   ├── 📄 Questions.js
│   │   │   └── 📄 StillQuestions.js
│   │   ├── 📁 landingpage/              # Landing page
│   │   │   └── 📄 Landingpage.js
│   │   ├── 📁 pricing/                  # Precios
│   │   │   └── 📄 Pricing.js
│   │   ├── 📁 rollbaseASL/              # RollbaseASL
│   │   │   └── 📄 RollbaseASL.js
│   │   ├── 📁 treeview/                 # Vista árbol
│   │   │   └── 📄 Treeview.js
│   │   ├── 📁 spinner/                  # Cargadores
│   │   │   ├── 📄 spinner.css
│   │   │   └── 📄 Spinner.js
│   │   └── 📁 tables/                   # Tablas
│   │       ├── 📄 BasicTable.js
│   │       ├── 📄 CollapsibleTable.js
│   │       ├── 📄 EnhancedTable.js
│   │       ├── 📄 FixedHeaderTable.js
│   │       ├── 📄 PaginationTable.js
│   │       ├── 📄 SearchTable.js
│   │       └── 📄 tableData.js
│   │
│   ├── 📁 shared/                       # Componentes compartidos
│   │   ├── 📁 breadcrumb/               # Migas de pan
│   │   │   └── 📄 Breadcrumb.js         # ⭐ Breadcrumb
│   │   ├── 📁 customizer/               # Personalizador
│   │   │   ├── 📄 Customizer.js         # ⭐ Customizer
│   │   │   └── 📄 RTL.js                # ⭐ RTL support
│   │   ├── 📁 loadable/                 # Carga lazy
│   │   │   └── 📄 Loadable.js           # ⭐ Loadable
│   │   ├── 📁 logo/                     # Logo
│   │   │   └── 📄 Logo.js               # ⭐ Logo componente
│   │   └── 📁 welcome/                  # Bienvenida
│   │       └── 📄 Welcome.js            # ⭐ Welcome
│   │
│   ├── 📁 ui-components/                # Componentes UI
│   │   ├── 📄 MuiAccordion.js          # ⭐ Acordeón
│   │   ├── 📄 MuiAlert.js              # ⭐ Alertas
│   │   ├── 📄 MuiAvatar.js             # ⭐ Avatar
│   │   ├── 📄 MuiChip.js               # ⭐ Chips
│   │   ├── 📄 MuiDialog.js             # ⭐ Diálogos
│   │   ├── 📄 MuiList.js               # ⭐ Listas
│   │   ├── 📄 MuiPopover.js            # ⭐ Popovers
│   │   ├── 📄 MuiRating.js             # ⭐ Rating
│   │   ├── 📄 MuiTabs.js               # ⭐ Tabs
│   │   ├── 📄 MuiTooltip.js            # ⭐ Tooltips
│   │   ├── 📄 MuiTransferList.js       # ⭐ Transfer List
│   │   └── 📄 MuiTypography.js         # ⭐ Tipografía
│   │
│   ├── 📁 widgets/                      # Widgets
│   │   ├── 📁 banners/                  # Banners
│   │   │   ├── 📄 Banner1.js
│   │   │   ├── 📄 Banner2.js
│   │   │   ├── 📄 Banner3.js
│   │   │   ├── 📄 Banner4.js
│   │   │   ├── 📄 Banner5.js
│   │   │   └── 📄 WidgetBanners.js
│   │   ├── 📁 cards/                    # Tarjetas
│   │   │   ├── 📄 ComplexCard.js
│   │   │   ├── 📄 EcommerceCard.js
│   │   │   ├── 📄 FollowerCard.js
│   │   │   ├── 📄 FriendCard.js
│   │   │   ├── 📄 GiftCard.js
│   │   │   ├── 📄 MusicCard.js
│   │   │   ├── 📄 ProfileCard.js
│   │   │   ├── 📄 Settings.js
│   │   │   ├── 📄 UpcomingActivity.js
│   │   │   └── 📄 WidgetCards.js
│   │   └── 📁 charts/                   # Gráficos
│   │       ├── 📄 CurrentValue.js
│   │       ├── 📄 Earned.js
│   │       ├── 📄 Followers.js
│   │       ├── 📄 MostVisited.js
│   │       ├── 📄 PageImpressions.js
│   │       ├── 📄 Views.js
│   │       └── 📄 WidgetCharts.js
│   │
│   ├── 📁 layouts/                      # Layouts principales
│   │   ├── 📁 blank/                    # Layout vacío
│   │   │   └── 📄 BlankLayout.js        # ⭐ Layout blanco
│   │   ├── 📁 full/                     # Layout completo
│   │   │   ├── 📁 horizontal/           # Layout horizontal
│   │   │   │   └── 📁 header/           # Header horizontal
│   │   │   │       └── 📄 Header.js
│   │   │   │   └── 📁 navbar/           # Navbar horizontal
│   │   │   │       ├── 📁 NavCollapse/  # Navegación colapsable
│   │   │   │       │   └── 📄 NavCollapse.js
│   │   │   │       ├── 📁 NavItem/      # Items navegación
│   │   │   │       │   └── 📄 NavItem.js
│   │   │   │       └── 📁 NavListing/   # Lista navegación
│   │   │   │           ├── 📄 NavListing.js
│   │   │   │           ├── 📄 Menudata.js
│   │   │   │           └── 📄 Navbar.js
│   │   │   └── 📁 vertical/             # Layout vertical
│   │   │       ├── 📁 header/           # Header vertical
│   │   │       │   ├── 📄 AppLinks.js
│   │   │       │   ├── 📄 Cart.js
│   │   │       │   ├── 📄 CartItems.js
│   │   │       │   ├── 📄 data.js
│   │   │       │   ├── 📄 dropdownData.js
│   │   │       │   ├── 📄 Header.js     # ⭐ Header vertical
│   │   │       │   ├── 📄 Language.js
│   │   │       │   ├── 📄 MobileRightSidebar.js
│   │   │       │   ├── 📄 Navigations.js
│   │   │       │   ├── 📄 Notifications.js
│   │   │       │   ├── 📄 Profile.js
│   │   │       │   ├── 📄 QuickLinks.js
│   │   │       │   └── 📄 Search.js
│   │   │       └── 📁 sidebar/          # Sidebar vertical
│   │   │           ├── 📁 NavCollapse/  # Navegación colapsable
│   │   │           │   └── 📄 index.js
│   │   │           ├── 📁 NavGroup/     # Grupos navegación
│   │   │           │   └── 📄 NavGroup.js
│   │   │           ├── 📁 NavItem/      # Items navegación
│   │   │           │   └── 📄 index.js
│   │   │           ├── 📁 SidebarProfile/ # Perfil sidebar
│   │   │           │   └── 📄 Profile.js
│   │   │           ├── 📄 MenuItems.js  # ⭐ Items menú
│   │   │           ├── 📄 Sidebar.js    # ⭐ Sidebar principal
│   │   │           ├── 📄 SidebarItems.js
│   │   │           └── 📄 FullLayout.js # ⭐ Layout completo
│   │
│   ├── 📁 routes/                       # Rutas aplicación
│   │   └── 📄 Router.js                 # ⭐ Router principal
│   │
│   ├── 📁 store/                        # Estado global
│   │   ├── 📁 apps/                     # Store aplicaciones
│   │   │   ├── 📁 blog/                 # Store blog
│   │   │   │   └── 📄 BlogSlice.js
│   │   │   ├── 📁 chat/                 # Store chat
│   │   │   │   └── 📄 ChatSlice.js
│   │   │   ├── 📁 contacts/             # Store contactos
│   │   │   │   └── 📄 ContactSlice.js
│   │   │   ├── 📁 eCommerce/            # Store ecommerce
│   │   │   │   ├── 📄 EcommerceSlice.js
│   │   │   │   ├── 📄 EcommerceCheckout.js
│   │   │   │   ├── 📄 EcommerceDetail.js
│   │   │   │   └── 📄 EcomProductList.js
│   │   │   ├── 📁 email/                # Store email
│   │   │   │   └── 📄 EmailSlice.js
│   │   │   ├── 📁 notes/                # Store notas
│   │   │   │   └── 📄 NotesSlice.js
│   │   │   ├── 📁 tickets/              # Store tickets
│   │   │   │   └── 📄 TicketSlice.js
│   │   │   └── 📁 userProfile/          # Store perfil
│   │   │       ├── 📄 UserProfileSlice.js
│   │   │       ├── 📄 Followers.js
│   │   │       ├── 📄 Friends.js
│   │   │       ├── 📄 Gallery.js
│   │   │       └── 📄 UserProfile.js
│   │   ├── 📁 customizer/               # Store customizer
│   │   │   ├── 📄 CustomizerSlice.js    # ⭐ Configuración tema
│   │   │   └── 📄 Store.js              # ⭐ Store principal
│   │   ├── 📁 theme/                    # Store tema
│   │   │   ├── 📄 Components.js         # ⭐ Componentes tema
│   │   │   ├── 📄 DarkThemeColors.js    # ⭐ Colores tema oscuro
│   │   │   ├── 📄 DefaultColors.js      # ⭐ Colores por defecto
│   │   │   ├── 📄 LightThemeColors.js   # ⭐ Colores tema claro
│   │   │   ├── 📄 Shadows.js            # ⭐ Sombras
│   │   │   ├── 📄 Theme.js              # ⭐ Tema principal
│   │   │   └── 📄 Typography.js         # ⭐ Tipografía
│   │   └── 📁 utils/                    # Utilidades store
│   │       ├── 📁 languages/            # Idiomas
│   │       │   ├── 📄 ar.json           # Árabe
│   │       │   ├── 📄 ch.json           # Chino
│   │       │   ├── 📄 en.json           # Inglés
│   │       │   ├── 📄 fr.json           # Francés
│   │       │   ├── 📄 axios.js          # ⭐ Cliente HTTP
│   │       │   └── 📄 i18n.js           # ⭐ Internacionalización
│   │
│   ├── 📁 views/                        # Vistas aplicación
│   │   ├── 📁 apps/                     # Vistas aplicaciones
│   │   │   ├── 📁 blog/                 # Vistas blog
│   │   │   │   ├── 📄 Blog.js           # ⭐ Lista blog
│   │   │   │   └── 📄 BlogPost.js       # ⭐ Post blog
│   │   │   ├── 📁 calendar/             # Vista calendario
│   │   │   │   ├── 📄 BigCalendar.js    # ⭐ Calendario principal
│   │   │   │   ├── 📄 Calendar.css
│   │   │   │   └── 📄 EventData.js
│   │   │   ├── 📁 chat/                 # Vista chat
│   │   │   │   └── 📄 Chat.js           # ⭐ Chat principal
│   │   │   ├── 📁 contacts/             # Vista contactos
│   │   │   │   └── 📄 Contacts.js       # ⭐ Lista contactos
│   │   │   ├── 📁 eCommerce/            # Vistas ecommerce
│   │   │   │   ├── 📄 Ecommerce.js      # ⭐ Tienda principal
│   │   │   │   ├── 📄 EcommerceCheckout.js # ⭐ Checkout
│   │   │   │   ├── 📄 EcommerceDetail.js   # ⭐ Detalle producto
│   │   │   │   └── 📄 EcomProductList.js   # ⭐ Lista productos
│   │   │   ├── 📁 email/                # Vista email
│   │   │   │   └── 📄 Email.js          # ⭐ Email principal
│   │   │   ├── 📁 notes/                # Vista notas
│   │   │   │   └── 📄 Notes.js          # ⭐ Notas principal
│   │   │   ├── 📁 tickets/              # Vista tickets
│   │   │   │   └── 📄 Tickets.js        # ⭐ Lista tickets
│   │   │   └── 📁 user-profile/         # Vista perfil
│   │   │       ├── 📄 Followers.js      # ⭐ Seguidores
│   │   │       ├── 📄 Friends.js        # ⭐ Amigos
│   │   │       ├── 📄 Gallery.js        # ⭐ Galería
│   │   │       └── 📄 UserProfile.js    # ⭐ Perfil usuario
│   │   ├── 📁 authentication/           # Vistas autenticación
│   │   │   ├── 📁 auth1/                # Auth estilo 1
│   │   │   │   ├── 📄 ForgotPassword.js # ⭐ Recuperar contraseña
│   │   │   │   ├── 📄 Login.js          # ⭐ Login
│   │   │   │   ├── 📄 Register.js       # ⭐ Registro
│   │   │   │   └── 📄 TwoSteps.js       # ⭐ Dos pasos
│   │   │   ├── 📁 auth2/                # Auth estilo 2
│   │   │   │   ├── 📄 ForgotPassword2.js
│   │   │   │   ├── 📄 Login2.js
│   │   │   │   ├── 📄 Register2.js
│   │   │   │   └── 📄 TwoSteps2.js
│   │   │   ├── 📁 authForms/            # Formularios auth
│   │   │   │   ├── 📄 AuthForgotPassword.js
│   │   │   │   ├── 📄 AuthLogin.js      # ⭐ Form login
│   │   │   │   ├── 📄 AuthRegister.js   # ⭐ Form registro
│   │   │   │   ├── 📄 AuthSocialButtons.js
│   │   │   │   └── 📄 AuthTwoSteps.js
│   │   │   ├── 📄 Error.js              # ⭐ Página error
│   │   │   └── 📄 Maintenance.js        # ⭐ Mantenimiento
│   │   ├── 📁 charts/                   # Vistas gráficos
│   │   │   ├── 📄 AreaChart.js
│   │   │   ├── 📄 CandlestickChart.js
│   │   │   ├── 📄 ColumnChart.js
│   │   │   ├── 📄 DoughnutChart.js
│   │   │   ├── 📄 GredientChart.js
│   │   │   ├── 📄 LineChart.js
│   │   │   └── 📄 RadialbarChart.js
│   │   ├── 📁 dashboard/                # Vistas dashboard
│   │   │   ├── 📄 Ecommerce.js          # ⭐ Dashboard ecommerce
│   │   │   └── 📄 Modern.js             # ⭐ Dashboard moderno
│   │   ├── 📁 forms/                    # Vistas formularios
│   │   │   ├── 📁 form-elements/        # Elementos formulario
│   │   │   │   ├── 📄 MuiAutoComplete.js
│   │   │   │   ├── 📄 MuiButton.js
│   │   │   │   ├── 📄 MuiCheckbox.js
│   │   │   │   ├── 📄 MuiDateTime.js
│   │   │   │   ├── 📄 MuiRadio.js
│   │   │   │   ├── 📄 MuiSlider.js
│   │   │   │   └── 📄 MuiSwitch.js
│   │   │   ├── 📁 quill-editor/         # Editor Quill
│   │   │   │   ├── 📄 Quill.css
│   │   │   │   ├── 📄 QuillEditor.js
│   │   │   │   ├── 📄 FormCustom.js
│   │   │   │   ├── 📄 FormHorizontal.js
│   │   │   │   ├── 📄 FormLayouts.js
│   │   │   │   ├── 📄 FormValidation.js
│   │   │   │   ├── 📄 FormVertical.js
│   │   │   │   └── 📄 FormWizard.js
│   │   │   └── 📄 index.js
│   │   ├── 📁 pages/                    # Vistas páginas
│   │   │   ├── 📁 account-setting/      # Configuración cuenta
│   │   │   │   └── 📄 AccountSetting.js
│   │   │   ├── 📁 faq/                  # Preguntas frecuentes
│   │   │   │   └── 📄 Faq.js
│   │   │   ├── 📁 landingpage/          # Landing page
│   │   │   │   └── 📄 Landingpage.js
│   │   │   ├── 📁 pricing/              # Precios
│   │   │   │   └── 📄 Pricing.js
│   │   │   ├── 📁 rollbaseASL/          # RollbaseASL
│   │   │   │   └── 📄 RollbaseASL.js
│   │   │   ├── 📁 treeview/             # Vista árbol
│   │   │   │   └── 📄 Treeview.js
│   │   │   ├── 📁 spinner/              # Spinner
│   │   │   │   ├── 📄 spinner.css
│   │   │   │   └── 📄 Spinner.js
│   │   │   └── 📁 tables/               # Tablas
│   │   │       ├── 📄 BasicTable.js
│   │   │       ├── 📄 CollapsibleTable.js
│   │   │       ├── 📄 EnhancedTable.js
│   │   │       ├── 📄 FixedHeaderTable.js
│   │   │       ├── 📄 PaginationTable.js
│   │   │       └── 📄 SearchTable.js
│   │   └── 📁 ui-components/            # Vistas componentes UI
│   │       ├── 📄 MuiAccordion.js
│   │       ├── 📄 MuiAlert.js
│   │       ├── 📄 MuiAvatar.js
│   │       ├── 📄 MuiChip.js
│   │       ├── 📄 MuiDialog.js
│   │       ├── 📄 MuiList.js
│   │       ├── 📄 MuiPopover.js
│   │       ├── 📄 MuiRating.js
│   │       ├── 📄 MuiTabs.js
│   │       ├── 📄 MuiTooltip.js
│   │       ├── 📄 MuiTransferList.js
│   │       └── 📄 MuiTypography.js
│   │
│   └── 📁 widgets/                      # Widgets vista
│       ├── 📁 banners/                  # Widgets banners
│       │   └── 📄 WidgetBanners.js
│       ├── 📁 cards/                    # Widgets tarjetas
│       │   └── 📄 WidgetCards.js
│       └── 📁 charts/                   # Widgets gráficos
│           └── 📄 WidgetCharts.js
└── 📁 layouts/                          # Layouts principales
    └── 📄 layouts.js                    # ⭐ Configuración layouts

---

## 🏗️ Arquitectura de Componentes

### 📊 **Aplicaciones Principales**
```
🔑 Sistema de Autenticación
├── Login/Register/ForgotPassword
├── Two-Factor Authentication
└── Social Login Integration

📝 Sistema de Blog
├── Lista de Posts
├── Detalle de Post
├── Comentarios
└── Gestión de Contenido

💬 Sistema de Chat
├── Lista de Conversaciones
├── Mensajes en Tiempo Real
├── Sidebar de Contactos
└── Envío de Archivos

📞 Sistema de Contactos
├── Lista de Contactos
├── Búsqueda y Filtros
├── Detalles de Contacto
└── Gestión CRUD

🛒 Sistema de E-commerce
├── Catálogo de Productos
├── Carrito de Compras
├── Proceso de Checkout
├── Detalles de Producto
└── Gestión de Órdenes

📧 Sistema de Email
├── Bandeja de Entrada
├── Redactar Email
├── Organización por Carpetas
└── Búsqueda de Mensajes

📝 Sistema de Notas
├── Crear/Editar Notas
├── Organización por Categorías
├── Búsqueda de Notas
└── Notas Favoritas

🎫 Sistema de Tickets
├── Lista de Tickets
├── Estados de Tickets
├── Filtros y Búsqueda
└── Asignación de Tickets

👤 Perfiles de Usuario
├── Información Personal
├── Galería de Fotos
├── Lista de Amigos
├── Seguidores
└── Posts y Actividad
```

### 🎨 **Sistema de Temas**
```
🌗 Gestión de Temas
├── Tema Claro
├── Tema Oscuro
├── Colores Personalizables
├── Tipografía Configurable
└── Sombras y Efectos

🌍 Internacionalización
├── Soporte Multi-idioma
├── Árabe (RTL)
├── Chino
├── Inglés
├── Francés
└── Configuración Regional
```

### 📱 **Layouts Responsivos**
```
🖥️ Layout Completo
├── Header con Navegación
├── Sidebar Colapsable
├── Área de Contenido Principal
└── Footer

📱 Layout Horizontal
├── Navegación Superior
├── Menús Desplegables
└── Contenido Fluido

📄 Layout Vacío
├── Solo Contenido
└── Sin Navegación (Auth)
```

### 🧩 **Componentes Reutilizables**
```
🎛️ Elementos de Formulario
├── Inputs Personalizados
├── Selectores Avanzados
├── Autocompletado
├── Validación en Tiempo Real
└── Elementos Material-UI

📊 Componentes de Datos
├── Tablas Avanzadas
├── Gráficos Interactivos
├── Listas Transferibles
└── Árboles de Navegación

🎨 Elementos UI
├── Modales y Diálogos
├── Tooltips y Popovers
├── Alertas y Notificaciones
├── Acordeones y Tabs
└── Avatares y Chips
```

---

## 🔧 **Tecnologías Principales**

### ⚛️ **Frontend Stack**
- **React 18** - Biblioteca UI principal
- **Vite** - Herramienta de construcción rápida
- **Material-UI (MUI)** - Sistema de diseño
- **Redux Toolkit** - Gestión de estado
- **React Router** - Navegación SPA
- **Axios** - Cliente HTTP
- **i18next** - Internacionalización

### 🎨 **Styling & UI**
- **Material-UI Components** - Componentes pre-diseñados
- **Custom Theme System** - Temas personalizables
- **Responsive Design** - Diseño adaptativo
- **Dark/Light Mode** - Modo oscuro/claro
- **CSS-in-JS** - Estilos en JavaScript

### 📦 **Gestión de Estado**
- **Redux Store** - Estado global
- **Slices por Módulo** - Organización modular
- **Async Thunks** - Operaciones asíncronas
- **Middleware** - Interceptores y logs

---

## 🚀 **Características Destacadas**

### ✨ **Funcionalidades Avanzadas**
- 🔐 **Autenticación Completa** - Login, registro, 2FA
- 🌐 **Multi-idioma** - Soporte internacional
- 📱 **Totalmente Responsivo** - Mobile-first design
- 🎨 **Temas Personalizables** - Dark/Light mode
- 📊 **Dashboards Interactivos** - Analíticas en tiempo real
- 🛒 **E-commerce Completo** - Tienda online funcional
- 💬 **Chat en Tiempo Real** - Mensajería instantánea
- 📧 **Sistema de Email** - Gestión de correos
- 🎫 **Gestión de Tickets** - Sistema de soporte

### 🎯 **Componentes Especializados**
- **Landing Page** - Página de presentación profesional
- **Dashboards** - Ecommerce y Modern variants
- **Forms** - Validación avanzada y elementos custom
- **Charts** - Gráficos interactivos con ApexCharts
- **Tables** - Tablas avanzadas con filtros y paginación
- **Widgets** - Componentes reutilizables modulares

### 🔧 **Herramientas de Desarrollo**
- **ESLint** - Linting de código
- **Prettier** - Formateo automático
- **Hot Reload** - Recarga en desarrollo
- **Build Optimization** - Optimización de producción
- **Environment Variables** - Configuración por entorno