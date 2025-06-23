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
│   │   ├── 📄 index.js                  # Exportaciones principales
│   │   ├── 📄 mock.js                   # Configuración mock
│   │   ├── 📁 blog/                     # Mock datos blog
│   │   │   └── 📄 blogData.js
│   │   ├── 📁 chat/                     # Mock datos chat
│   │   │   └── 📄 Chatdata.js
│   │   ├── 📁 contacts/                 # Mock datos contactos
│   │   │   └── 📄 ContactsData.js
│   │   ├── 📁 eCommerce/                # Mock datos ecommerce
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
│   │   ├── 📄 react.svg                 # Logo React
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
│   │       │   ├── 📄 errorimg.svg
│   │       │   ├── 📄 login-bg.svg
│   │       │   ├── 📄 maintenance.svg
│   │       │   ├── 📄 maintenance2.svg
│   │       │   └── 📄 welcome-bg.svg
│   │       ├── 📁 blog/                 # Imágenes del blog
│   │       │   ├── 📄 blog-img1.jpg
│   │       │   ├── 📄 blog-img2.jpg
│   │       │   ├── 📄 blog-img3.jpg
│   │       │   ├── 📄 blog-img4.jpg
│   │       │   ├── 📄 blog-img5.jpg
│   │       │   ├── 📄 blog-img6.jpg
│   │       │   ├── 📄 blog-img8.jpg
│   │       │   ├── 📄 blog-img9.jpg
│   │       │   ├── 📄 blog-img10.jpg
│   │       │   └── 📄 blog-img11.jpg
│   │       ├── 📁 breadcrumb/           # Migas de pan
│   │       │   ├── 📄 ChatBc.png
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
│   │       │   ├── 📄 bannerimg1.svg
│   │       │   ├── 📄 bannerimg2.svg
│   │       │   ├── 📄 favicon.png
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
│   │       │   ├── 📁 profile/          # Imágenes perfil landing
│   │       │   │   ├── 📄 testimonial1.png
│   │       │   │   ├── 📄 testimonial2.png
│   │       │   │   ├── 📄 testimonial3.png
│   │       │   │   ├── 📄 user1.png
│   │       │   │   ├── 📄 user2.png
│   │       │   │   └── 📄 user3.png
│   │       │   └── 📁 shape/            # Elementos gráficos
│   │       │       ├── 📄 badge.png
│   │       │       ├── 📄 badge.svg
│   │       │       ├── 📄 line-bg-2.svg
│   │       │       ├── 📄 line-bg.svg
│   │       │       ├── 📄 shape-1.svg
│   │       │       └── 📄 shape-2.svg
│   │       ├── 📁 logos/                # Logos aplicación
│   │       │   ├── 📄 dark-logo.svg
│   │       │   ├── 📄 dark-rtl-logo.svg
│   │       │   ├── 📄 light-logo-rtl.svg
│   │       │   ├── 📄 light-logo.svg
│   │       │   └── 📄 logoIcon.svg
│   │       ├── 📁 products/             # Imágenes productos
│   │       │   ├── 📄 empty-shopping-bag2.gif
│   │       │   ├── 📄 empty-shopping-cart.svg
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
│   │       ├── 📁 profile/              # Imágenes perfil usuarios
│   │       │   ├── 📄 user-1.jpg
│   │       │   ├── 📄 user-2.jpg
│   │       │   ├── 📄 user-3.jpg
│   │       │   ├── 📄 user-4.jpg
│   │       │   ├── 📄 user-5.jpg
│   │       │   ├── 📄 user-6.jpg
│   │       │   ├── 📄 user-7.jpg
│   │       │   ├── 📄 user-8.jpg
│   │       │   ├── 📄 user-9.jpg
│   │       │   └── 📄 user-10.jpg
│   │       └── 📁 svgs/                 # Iconos SVG
│   │           ├── 📄 cart-icon.svg
│   │           ├── 📄 facebook-icon.svg
│   │           ├── 📄 google-icon.svg
│   │           ├── 📄 icon-account.svg
│   │           ├── 📄 icon-bars.svg
│   │           ├── 📄 icon-briefcase.svg
│   │           ├── 📄 icon-connect.svg
│   │           ├── 📄 icon-dd-application.svg
│   │           ├── 📄 icon-dd-cart.svg
│   │           ├── 📄 icon-dd-chat.svg
│   │           ├── 📄 icon-dd-date.svg
│   │           ├── 📄 icon-dd-invoice.svg
│   │           ├── 📄 icon-dd-lifebuoy.svg
│   │           ├── 📄 icon-dd-message-box.svg
│   │           ├── 📄 icon-dd-mobile.svg
│   │           ├── 📄 icon-favorites.svg
│   │           ├── 📄 icon-inbox.svg
│   │           ├── 📄 icon-mailbox.svg
│   │           ├── 📄 icon-master-card-2.svg
│   │           ├── 📄 icon-master-card.svg
│   │           ├── 📄 icon-office-bag-2.svg
│   │           ├── 📄 icon-office-bag.svg
│   │           ├── 📄 icon-paypal.svg
│   │           ├── 📄 icon-pie.svg
│   │           ├── 📄 icon-speech-bubble.svg
│   │           ├── 📄 icon-tasks.svg
│   │           ├── 📄 icon-user-male.svg
│   │           ├── 📄 mastercard.svg
│   │           ├── 📄 paypal.svg
│   │           └── 📄 react.svg
│   │
│   ├── 📁 components/                   # Componentes React
│   │   ├── 📁 apps/                     # Aplicaciones principales
│   │   │   ├── 📁 blog/                 # Sistema de blog
│   │   │   │   ├── 📄 BlogCard.js
│   │   │   │   ├── 📄 BlogFeaturedCard.js
│   │   │   │   ├── 📄 BlogListing.js
│   │   │   │   └── 📁 detail/           # Detalle del blog
│   │   │   │       ├── 📄 BlogComment.js
│   │   │   │       └── 📄 BlogDetail.js
│   │   │   ├── 📁 chats/                # Sistema de chat
│   │   │   │   ├── 📄 ChatContent.js
│   │   │   │   ├── 📄 ChatInsideSidebar.js
│   │   │   │   ├── 📄 ChatListing.js
│   │   │   │   ├── 📄 ChatMsgSent.js
│   │   │   │   └── 📄 ChatSidebar.js
│   │   │   ├── 📁 contacts/             # Gestión contactos
│   │   │   │   ├── 📄 ContactAdd.js
│   │   │   │   ├── 📄 ContactDetails.js
│   │   │   │   ├── 📄 ContactFilter.js
│   │   │   │   ├── 📄 ContactList.js
│   │   │   │   ├── 📄 ContactListItem.js
│   │   │   │   └── 📄 ContactSearch.js
│   │   │   ├── 📁 ecommerce/            # Sistema ecommerce
│   │   │   │   ├── 📁 productCart/      # Carrito compras
│   │   │   │   │   ├── 📄 AddToCart.js
│   │   │   │   │   └── 📄 AlertCart.js
│   │   │   │   ├── 📁 productCheckout/  # Checkout proceso
│   │   │   │   │   ├── 📄 FinalStep.js
│   │   │   │   │   ├── 📄 FirstStep.js
│   │   │   │   │   ├── 📄 HorizontalStepper.js
│   │   │   │   │   ├── 📄 ProductCheckout.js
│   │   │   │   │   ├── 📄 SecondStep.js
│   │   │   │   │   └── 📄 ThirdStep.js
│   │   │   │   ├── 📁 productDetail/    # Detalle producto
│   │   │   │   │   ├── 📄 Carousel.css
│   │   │   │   │   ├── 📄 ProductCarousel.js
│   │   │   │   │   ├── 📄 ProductDesc.js
│   │   │   │   │   ├── 📄 ProductDetail.js
│   │   │   │   │   ├── 📄 ProductRelated.js
│   │   │   │   │   └── 📄 SliderData.js
│   │   │   │   ├── 📁 productGrid/      # Grilla productos
│   │   │   │   │   ├── 📄 ProductFilter.js
│   │   │   │   │   ├── 📄 ProductList.js
│   │   │   │   │   ├── 📄 ProductSearch.js
│   │   │   │   │   └── 📄 ProductSidebar.js
│   │   │   │   └── 📁 ProductTableList/ # Tabla productos
│   │   │   │       └── 📄 ProductTableList.js
│   │   │   ├── 📁 email/                # Sistema email
│   │   │   │   ├── 📄 EmailActions.js
│   │   │   │   ├── 📄 EmailCompose.js
│   │   │   │   ├── 📄 EmailContent.js
│   │   │   │   ├── 📄 EmailFilter.js
│   │   │   │   ├── 📄 EmailList.js
│   │   │   │   ├── 📄 EmailListItem.js
│   │   │   │   └── 📄 EmailSearch.js
│   │   │   ├── 📁 notes/                # Sistema notas
│   │   │   │   ├── 📄 AddNotes.js
│   │   │   │   ├── 📄 NoteContent.js
│   │   │   │   ├── 📄 NoteList.js
│   │   │   │   └── 📄 NoteSidebar.js
│   │   │   ├── 📁 tickets/              # Sistema tickets
│   │   │   │   ├── 📄 TicketFilter.js
│   │   │   │   └── 📄 TicketListing.js
│   │   │   └── 📁 userprofile/          # Perfil usuario
│   │   │       ├── 📁 followers/        # Seguidores
│   │   │       │   └── 📄 FollowerCard.js
│   │   │       ├── 📁 friends/          # Amigos
│   │   │       │   └── 📄 FriendsCard.js
│   │   │       ├── 📁 gallery/          # Galería
│   │   │       │   └── 📄 GalleryCard.js
│   │   │       └── 📁 profile/          # Perfil
│   │   │           ├── 📄 IntroCard.js
│   │   │           ├── 📄 PhotosCard.js
│   │   │           ├── 📄 Post.js
│   │   │           ├── 📄 PostComments.js
│   │   │           ├── 📄 PostItem.js
│   │   │           ├── 📄 PostTextBox.js
│   │   │           ├── 📄 ProfileBanner.js
│   │   │           └── 📄 ProfileTab.js
│   │   ├── 📁 container/                # Contenedores
│   │   │   └── 📄 PageContainer.js
│   │   ├── 📁 custom-scroll/            # Scroll personalizado
│   │   │   └── 📄 Scrollbar.js
│   │   ├── 📁 dashboards/               # Dashboards
│   │   │   ├── 📁 ecommerce/            # Dashboard ecommerce
│   │   │   │   ├── 📄 Expence.js
│   │   │   │   ├── 📄 Growth.js
│   │   │   │   ├── 📄 MonthlyEarnings.js
│   │   │   │   ├── 📄 PaymentGateways.js
│   │   │   │   ├── 📄 ProductPerformances.js
│   │   │   │   ├── 📄 RecentTransactions.js
│   │   │   │   ├── 📄 RevenueUpdates.js
│   │   │   │   ├── 📄 Sales.js
│   │   │   │   ├── 📄 SalesOverview.js
│   │   │   │   ├── 📄 SalesTwo.js
│   │   │   │   ├── 📄 TotalEarning.js
│   │   │   │   ├── 📄 WelcomeCard.js
│   │   │   │   └── 📄 YearlySales.js
│   │   │   └── 📁 modern/               # Dashboard moderno
│   │   │       ├── 📄 Customers.js
│   │   │       ├── 📄 EmployeeSalary.js
│   │   │       ├── 📄 MonthlyEarnings.js
│   │   │       ├── 📄 Projects.js
│   │   │       ├── 📄 RevenueUpdates.js
│   │   │       ├── 📄 SellingProducts.js
│   │   │       ├── 📄 Social.js
│   │   │       ├── 📄 TopCards.js
│   │   │       ├── 📄 TopPerformerData.js
│   │   │       ├── 📄 TopPerformers.js
│   │   │       ├── 📄 WeeklyStats.js
│   │   │       └── 📄 YearlyBreakup.js
│   │   ├── 📁 forms/                    # Componentes formularios
│   │   │   ├── 📁 form-elements/        # Elementos formulario
│   │   │   │   ├── 📁 autoComplete/     # Autocompletado
│   │   │   │   │   ├── 📄 CheckboxesAutocomplete.js
│   │   │   │   │   ├── 📄 ComboBoxAutocomplete.js
│   │   │   │   │   ├── 📄 ControlledStateAutocomplete.js
│   │   │   │   │   ├── 📄 countrydata.js
│   │   │   │   │   ├── 📄 CountrySelectAutocomplete.js
│   │   │   │   │   ├── 📄 data.js
│   │   │   │   │   ├── 📄 FreeSoloAutocomplete.js
│   │   │   │   │   ├── 📄 MultipleValuesAutocomplete.js
│   │   │   │   │   └── 📄 SizesAutocomplete.js
│   │   │   │   ├── 📁 button/           # Botones
│   │   │   │   │   ├── 📄 ColorButtonGroup.js
│   │   │   │   │   ├── 📄 ColorButtons.js
│   │   │   │   │   ├── 📄 DefaultButtonGroup.js
│   │   │   │   │   ├── 📄 DefaultButtons.js
│   │   │   │   │   ├── 📄 FabColorButtons.js
│   │   │   │   │   ├── 📄 FabDefaultButton.js
│   │   │   │   │   ├── 📄 FabSizeButtons.js
│   │   │   │   │   ├── 📄 IconColorButtons.js
│   │   │   │   │   ├── 📄 IconLoadingButtons.js
│   │   │   │   │   ├── 📄 IconSizeButtons.js
│   │   │   │   │   ├── 📄 OutlinedColorButtons.js
│   │   │   │   │   ├── 📄 OutlinedDefaultButtons.js
│   │   │   │   │   ├── 📄 OutlinedIconButtons.js
│   │   │   │   │   ├── 📄 OutlinedSizeButton.js
│   │   │   │   │   ├── 📄 SizeButton.js
│   │   │   │   │   ├── 📄 SizeButtonGroup.js
│   │   │   │   │   ├── 📄 TextButtonGroup.js
│   │   │   │   │   ├── 📄 TextColorButtons.js
│   │   │   │   │   ├── 📄 TextDefaultButtons.js
│   │   │   │   │   ├── 📄 TextIconButtons.js
│   │   │   │   │   ├── 📄 TextSizeButton.js
│   │   │   │   │   └── 📄 VerticalButtonGroup.js
│   │   │   │   ├── 📁 checkbox/         # Checkboxes
│   │   │   │   │   ├── 📄 Colors.js
│   │   │   │   │   ├── 📄 Custom.js
│   │   │   │   │   ├── 📄 Default.js
│   │   │   │   │   ├── 📄 DefaultColors.js
│   │   │   │   │   ├── 📄 Position.js
│   │   │   │   │   └── 📄 Sizes.js
│   │   │   │   ├── 📁 radio/            # Radio buttons
│   │   │   │   │   ├── 📄 ColorLabel.js
│   │   │   │   │   ├── 📄 Colors.js
│   │   │   │   │   ├── 📄 Custom.js
│   │   │   │   │   ├── 📄 Default.js
│   │   │   │   │   ├── 📄 Position.js
│   │   │   │   │   └── 📄 Sizes.js
│   │   │   │   └── 📁 switch/           # Switches
│   │   │   │       ├── 📄 Colors.js
│   │   │   │       ├── 📄 Custom.js
│   │   │   │       ├── 📄 Default.js
│   │   │   │       ├── 📄 DefaultLabel.js
│   │   │   │       ├── 📄 Position.js
│   │   │   │       └── 📄 Sizes.js
│   │   │   ├── 📁 form-horizontal/      # Formularios horizontales
│   │   │   │   ├── 📄 BasicIcons.js
│   │   │   │   ├── 📄 BasicLayout.js
│   │   │   │   ├── 📄 CollapsibleForm.js
│   │   │   │   ├── 📄 FormLabelAlignment.js
│   │   │   │   ├── 📄 FormSeparator.js
│   │   │   │   └── 📄 FormTabs.js
│   │   │   ├── 📁 form-layouts/         # Layouts formularios
│   │   │   │   ├── 📄 FbBasicHeaderForm.js
│   │   │   │   ├── 📄 FbDefaultForm.js
│   │   │   │   ├── 📄 FbDisabledForm.js
│   │   │   │   ├── 📄 FbInputVariants.js
│   │   │   │   ├── 📄 FbLeftIconForm.js
│   │   │   │   ├── 📄 FbOrdinaryForm.js
│   │   │   │   ├── 📄 FbReadonlyForm.js
│   │   │   │   ├── 📄 FbRightIconForm.js
│   │   │   │   └── 📄 index.js
│   │   │   ├── 📁 form-validation/      # Validación formularios
│   │   │   │   ├── 📄 FVCheckbox.js
│   │   │   │   ├── 📄 FVLogin.js
│   │   │   │   ├── 📄 FVOnLeave.js
│   │   │   │   ├── 📄 FVRadio.js
│   │   │   │   ├── 📄 FVRegister.js
│   │   │   │   └── 📄 FVSelect.js
│   │   │   ├── 📁 form-vertical/        # Formularios verticales
│   │   │   │   ├── 📄 BasicIcons.js
│   │   │   │   ├── 📄 BasicLayout.js
│   │   │   │   ├── 📄 CollapsibleForm.js
│   │   │   │   ├── 📄 FormSeparator.js
│   │   │   │   └── 📄 FormTabs.js
│   │   │   └── 📁 theme-elements/       # Elementos temáticos
│   │   │       ├── 📄 CustomCheckbox.js
│   │   │       ├── 📄 CustomDisabledButton.js
│   │   │       ├── 📄 CustomFormLabel.js
│   │   │       ├── 📄 CustomOutlinedButton.js
│   │   │       ├── 📄 CustomOutlinedInput.js
│   │   │       ├── 📄 CustomRadio.js
│   │   │       ├── 📄 CustomRangeSlider.js
│   │   │       ├── 📄 CustomSelect.js
│   │   │       ├── 📄 CustomSlider.js
│   │   │       ├── 📄 CustomSocialButton.js
│   │   │       ├── 📄 CustomSwitch.js
│   │   │       └── 📄 CustomTextField.js
│   │   ├── 📁 landingpage/              # Página de inicio
│   │   │   ├── 📁 animation/            # Animaciones
│   │   │   │   └── 📄 Animation.js
│   │   │   ├── 📁 banner/               # Banner principal
│   │   │   │   ├── 📄 Banner.js
│   │   │   │   └── 📄 BannerContent.js
│   │   │   ├── 📁 c2a/                  # Call to Action
│   │   │   │   ├── 📄 C2a.js
│   │   │   │   ├── 📄 C2a2.js
│   │   │   │   └── 📄 GuaranteeCard.js
│   │   │   ├── 📁 demo-slider/          # Slider demos
│   │   │   │   ├── 📄 demo-slider.css
│   │   │   │   ├── 📄 DemoSlider.js
│   │   │   │   └── 📄 DemoTitle.js
│   │   │   ├── 📁 features/             # Características
│   │   │   │   ├── 📄 Features.js
│   │   │   │   └── 📄 FeaturesTitle.js
│   │   │   ├── 📁 footer/               # Pie de página
│   │   │   │   └── 📄 Footer.js
│   │   │   ├── 📁 frameworks/           # Marcos de trabajo
│   │   │   │   ├── 📄 Frameworks.js
│   │   │   │   └── 📄 FrameworksTitle.js
│   │   │   ├── 📁 header/               # Cabecera
│   │   │   │   ├── 📄 DemosDD.js
│   │   │   │   ├── 📄 Header.js
│   │   │   │   ├── 📄 MobileSidebar.js
│   │   │   │   └── 📄 Navigations.js
│   │   │   └── 📁 testimonial/          # Testimonios
│   │   │       ├── 📄 testimonial.css
│   │   │       ├── 📄 Testimonial.js
│   │   │       └── 📄 TestimonialTitle.js
│   │   ├── 📁 material-ui/              # Componentes Material-UI
│   │   │   ├── 📁 dialog/               # Diálogos
│   │   │   │   ├── 📄 AlertDialog.js
│   │   │   │   ├── 📄 FormDialog.js
│   │   │   │   ├── 📄 FullscreenDialog.js
│   │   │   │   ├── 📄 MaxWidthDialog.js
│   │   │   │   ├── 📄 ResponsiveDialog.js
│   │   │   │   ├── 📄 ScrollContentDialog.js
│   │   │   │   ├── 📄 SimpleDialog.js
│   │   │   │   └── 📄 TransitionDialog.js
│   │   │   ├── 📁 lists/                # Listas
│   │   │   │   ├── 📄 ControlsList.js
│   │   │   │   ├── 📄 FolderList.js
│   │   │   │   ├── 📄 NestedList.js
│   │   │   │   ├── 📄 SelectedList.js
│   │   │   │   ├── 📄 SimpleList.js
│   │   │   │   └── 📄 SwitchList.js
│   │   │   ├── 📁 popover/              # Popovers
│   │   │   │   ├── 📄 ClickPopover.js
│   │   │   │   └── 📄 HoverPopover.js
│   │   │   └── 📁 transfer-list/        # Lista transferencia
│   │   │       ├── 📄 BasicTransferList.js
│   │   │       └── 📄 EnhancedTransferList.js
│   │   ├── 📁 pages/                    # Páginas principales
│   │   │   ├── 📁 account-setting/      # Configuración cuenta
│   │   │   │   ├── 📄 AccountTab.js
│   │   │   │   ├── 📄 BillsTab.js
│   │   │   │   ├── 📄 NotificationTab.js
│   │   │   │   └── 📄 SecurityTab.js
│   │   │   └── 📁 faq/                  # Preguntas frecuentes
│   │   │       ├── 📄 Questions.js
│   │   │       └── 📄 StillQuestions.js
│   │   ├── 📁 shared/                   # Componentes compartidos
│   │   │   ├── 📄 AppCard.js
│   │   │   ├── 📄 BaseCard.js
│   │   │   ├── 📄 BlankCard.js
│   │   │   ├── 📄 ChildCard.js
│   │   │   ├── 📄 DashboardCard.js
│   │   │   ├── 📄 DashboardWidgetCard.js
│   │   │   ├── 📄 InlineItemCard.js
│   │   │   ├── 📄 ParentCard.js
│   │   │   ├── 📄 ScrollToTop.js
│   │   │   ├── 📄 ThreeColumn.js
│   │   │   └── 📄 WidgetCard.js
│   │   └── 📁 widgets/                  # Widgets
│   │       ├── 📁 banners/              # Banners
│   │       │   ├── 📄 Banner1.js
│   │       │   ├── 📄 Banner2.js
│   │       │   ├── 📄 Banner3.js
│   │       │   ├── 📄 Banner4.js
│   │       │   └── 📄 Banner5.js
│   │       ├── 📁 cards/                # Tarjetas
│   │       │   ├── 📄 ComplexCard.js
│   │       │   ├── 📄 EcommerceCard.js
│   │       │   ├── 📄 FollowerCard.js
│   │       │   ├── 📄 FriendCard.js
│   │       │   ├── 📄 GiftCard.js
│   │       │   ├── 📄 MusicCard.js
│   │       │   ├── 📄 ProfileCard.js
│   │       │   ├── 📄 Settings.js
│   │       │   └── 📄 UpcomingActivity.js
│   │       └── 📁 charts/               # Gráficos
│   │           ├── 📄 CurrentValue.js
│   │           ├── 📄 Earned.js
│   │           ├── 📄 Followers.js
│   │           ├── 📄 MostVisited.js
│   │           ├── 📄 PageImpressions.js
│   │           └── 📄 Views.js
│   │
│   ├── 📁 layouts/                      # Layouts principales
│   │   ├── 📁 blank/                    # Layout vacío
│   │   │   └── 📄 BlankLayout.js
│   │   └── 📁 full/                     # Layout completo
│   │       ├── 📄 FullLayout.js
│   │       ├── 📁 horizontal/           # Layout horizontal
│   │       │   ├── 📁 header/           # Header horizontal
│   │       │   │   └── 📄 Header.js
│   │       │   └── 📁 navbar/           # Navbar horizontal
│   │       │       ├── 📄 Menudata.js
│   │       │       ├── 📄 Navbar.js
│   │       │       ├── 📁 NavCollapse/  # Navegación colapsable
│   │       │       │   └── 📄 NavCollapse.js
│   │       │       ├── 📁 NavItem/      # Items navegación
│   │       │       │   └── 📄 NavItem.js
│   │       │       └── 📁 NavListing/   # Lista navegación
│   │       │           └── 📄 NavListing.js
│   │       ├── 📁 shared/               # Compartidos entre layouts
│   │       │   ├── 📁 breadcrumb/       # Migas de pan
│   │       │   │   └── 📄 Breadcrumb.js
│   │       │   ├── 📁 customizer/       # Personalizador
│   │       │   │   ├── 📄 Customizer.js
│   │       │   │   └── 📄 RTL.js
│   │       │   ├── 📁 loadable/         # Carga lazy
│   │       │   │   └── 📄 Loadable.js
│   │       │   ├── 📁 logo/             # Logo
│   │       │   │   └── 📄 Logo.js
│   │       │   └── 📁 welcome/          # Bienvenida
│   │       │       └── 📄 Welcome.js
│   │       └── 📁 vertical/             # Layout vertical
│   │           ├── 📁 header/           # Header vertical
│   │           │   ├── 📄 AppLinks.js
│   │           │   ├── 📄 Cart.js
│   │           │   ├── 📄 CartItems.js
│   │           │   ├── 📄 data.js
│   │           │   ├── 📄 dropdownData.js
│   │           │   ├── 📄 Header.js
│   │           │   ├── 📄 Language.js
│   │           │   ├── 📄 MobileRightSidebar.js
│   │           │   ├── 📄 Navigation.js
│   │           │   ├── 📄 Notifications.js
│   │           │   ├── 📄 Profile.js
│   │           │   ├── 📄 QuickLinks.js
│   │           │   └── 📄 Search.js
│   │           └── 📁 sidebar/          # Sidebar vertical
│   │               ├── 📄 MenuItems.js
│   │               ├── 📄 Sidebar.js
│   │               ├── 📄 SidebarItems.js
│   │               ├── 📁 NavCollapse/  # Navegación colapsable
│   │               │   └── 📄 index.js
│   │               ├── 📁 NavGroup/     # Grupos navegación
│   │               │   └── 📄 NavGroup.js
│   │               ├── 📁 NavItem/      # Items navegación
│   │               │   └── 📄 index.js
│   │               └── 📁 SidebarProfile/ # Perfil sidebar
│   │                   └── 📄 Profile.js
│   │
│   ├── 📁 routes/                       # Rutas aplicación
│   │   └── 📄 Router.js
│   │
│   ├── 📁 store/                        # Estado global
│   │   ├── 📄 Store.js
│   │   ├── 📁 apps/                     # Store aplicaciones
│   │   │   ├── 📁 blog/                 # Store blog
│   │   │   │   └── 📄 BlogSlice.js
│   │   │   ├── 📁 chat/                 # Store chat
│   │   │   │   └── 📄 ChatSlice.js
│   │   │   ├── 📁 contacts/             # Store contactos
│   │   │   │   └── 📄 ContactSlice.js
│   │   │   ├── 📁 eCommerce/            # Store ecommerce
│   │   │   │   └── 📄 EcommerceSlice.js
│   │   │   ├── 📁 email/                # Store email
│   │   │   │   └── 📄 EmailSlice.js
│   │   │   ├── 📁 notes/                # Store notas
│   │   │   │   └── 📄 NotesSlice.js
│   │   │   ├── 📁 tickets/              # Store tickets
│   │   │   │   └── 📄 TicketSlice.js
│   │   │   └── 📁 userProfile/          # Store perfil
│   │   │       └── 📄 UserProfileSlice.js
│   │   └── 📁 customizer/               # Store customizer
│   │       └── 📄 CustomizerSlice.js
│   │
│   ├── 📁 theme/                        # Configuración tema
│   │   ├── 📄 Components.js
│   │   ├── 📄 DarkThemeColors.js
│   │   ├── 📄 DefaultColors.js
│   │   ├── 📄 LightThemeColors.js
│   │   ├── 📄 Shadows.js
│   │   ├── 📄 Theme.js
│   │   └── 📄 Typography.js
│   │
│   ├── 📁 utils/                        # Utilidades
│   │   ├── 📄 axios.js
│   │   ├── 📄 i18n.js
│   │   └── 📁 languages/                # Idiomas
│   │       ├── 📄 ar.json
│   │       ├── 📄 ch.json
│   │       ├── 📄 en.json
│   │       └── 📄 fr.json
│   │
│   └── 📁 views/                        # Vistas aplicación
│       ├── 📁 apps/                     # Vistas aplicaciones
│       │   ├── 📁 blog/                 # Vistas blog
│       │   │   ├── 📄 Blog.js
│       │   │   └── 📄 BlogPost.js
│       │   ├── 📁 calendar/             # Vista calendario
│       │   │   ├── 📄 BigCalendar.js
│       │   │   ├── 📄 Calendar.css
│       │   │   └── 📄 EventData.js
│       │   ├── 📁 chat/                 # Vista chat
│       │   │   └── 📄 Chat.js
│       │   ├── 📁 contacts/             # Vista contactos
│       │   │   └── 📄 Contacts.js
│       │   ├── 📁 eCommerce/            # Vistas ecommerce
│       │   │   ├── 📄 Ecommerce.js
│       │   │   ├── 📄 EcommerceCheckout.js
│       │   │   ├── 📄 EcommerceDetail.js
│       │   │   └── 📄 EcomProductList.js
│       │   ├── 📁 email/                # Vista email
│       │   │   └── 📄 Email.js
│       │   ├── 📁 notes/                # Vista notas
│       │   │   └── 📄 Notes.js
│       │   ├── 📁 tickets/              # Vista tickets
│       │   │   └── 📄 Tickets.js
│       │   └── 📁 user-profile/         # Vista perfil
│       │       ├── 📄 Followers.js
│       │       ├── 📄 Friends.js
│       │       ├── 📄 Gallery.js
│       │       └── 📄 UserProfile.js
│       ├── 📁 authentication/           # Vistas autenticación
│       │   ├── 📄 Error.js
│       │   ├── 📄 Maintenance.js
│       │   ├── 📁 auth1/                # Auth estilo 1
│       │   │   ├── 📄 ForgotPassword.js
│       │   │   ├── 📄 Login.js
│       │   │   ├── 📄 Register.js
│       │   │   └── 📄 TwoSteps.js
│       │   ├── 📁 auth2/                # Auth estilo 2
│       │   │   ├── 📄 ForgotPassword2.js
│       │   │   ├── 📄 Login2.js
│       │   │   ├── 📄 Register2.js
│       │   │   └── 📄 TwoSteps2.js
│       │   └── 📁 authForms/            # Formularios auth
│       │       ├── 📄 AuthForgotPassword.js
│       │       ├── 📄 AuthLogin.js
│       │       ├── 📄 AuthRegister.js
│       │       ├── 📄 AuthSocialButtons.js
│       │       └── 📄 AuthTwoSteps.js
│       ├── 📁 charts/                   # Vistas gráficos
│       │   ├── 📄 AreaChart.js
│       │   ├── 📄 CandlestickChart.js
│       │   ├── 📄 ColumnChart.js
│       │   ├── 📄 DoughnutChart.js
│       │   ├── 📄 GredientChart.js
│       │   ├── 📄 LineChart.js
│       │   └── 📄 RadialbarChart.js
│       ├── 📁 dashboard/                # Vistas dashboard
│       │   ├── 📄 Ecommerce.js
│       │   └── 📄 Modern.js
│       ├── 📁 forms/                    # Vistas formularios
│       │   ├── 📄 FormCustom.js
│       │   ├── 📄 FormHorizontal.js
│       │   ├── 📄 FormLayouts.js
│       │   ├── 📄 FormValidation.js
│       │   ├── 📄 FormVertical.js
│       │   ├── 📄 FormWizard.js
│       │   ├── 📁 form-elements/        # Elementos formulario
│       │   │   ├── 📄 MuiAutoComplete.js
│       │   │   ├── 📄 MuiButton.js
│       │   │   ├── 📄 MuiCheckbox.js
│       │   │   ├── 📄 MuiDateTime.js
│       │   │   ├── 📄 MuiRadio.js
│       │   │   ├── 📄 MuiSlider.js
│       │   │   └── 📄 MuiSwitch.js
│       │   └── 📁 quill-editor/         # Editor Quill
│       │       ├── 📄 Quill.css
│       │       └── 📄 QuillEditor.js
│       ├── 📁 pages/                    # Vistas páginas
│       │   ├── 📁 account-setting/      # Configuración cuenta
│       │   │   └── 📄 AccountSetting.js
│       │   ├── 📁 faq/                  # Preguntas frecuentes
│       │   │   └── 📄 Faq.js
│       │   ├── 📁 landingpage/          # Landing page
│       │   │   └── 📄 Landingpage.js
│       │   ├── 📁 pricing/              # Precios
│       │   │   └── 📄 Pricing.js
│       │   ├── 📁 rollbaseCASL/         # RollbaseCASL
│       │   │   └── 📄 RollbaseCASL.js
│       │   └── 📁 treeview/             # Vista árbol
│       │       └── 📄 Treeview.js
│       ├── 📁 security/                 # Vistas de seguridad
│       │   ├── 📄 MenuManagement.js
│       │   ├── 📄 RoleManagement.js
│       │   ├── 📄 SecurityDashboard.js
│       │   └── 📄 UserManagement.js
│       ├── 📁 spinner/                  # Spinner
│       │   ├── 📄 spinner.css
│       │   └── 📄 Spinner.js
│       ├── 📁 tables/                   # Tablas
│       │   ├── 📄 BasicTable.js
│       │   ├── 📄 CollapsibleTable.js
│       │   ├── 📄 EnhancedTable.js
│       │   ├── 📄 FixedHeaderTable.js
│       │   ├── 📄 PaginationTable.js
│       │   ├── 📄 SearchTable.js
│       │   └── 📄 tableData.js
│       ├── 📁 ui-components/            # Vistas componentes UI
│       │   ├── 📄 MuiAccordion.js
│       │   ├── 📄 MuiAlert.js
│       │   ├── 📄 MuiAvatar.js
│       │   ├── 📄 MuiChip.js
│       │   ├── 📄 MuiDialog.js
│       │   ├── 📄 MuiList.js
│       │   ├── 📄 MuiPopover.js
│       │   ├── 📄 MuiRating.js
│       │   ├── 📄 MuiTabs.js
│       │   ├── 📄 MuiTooltip.js
│       │   ├── 📄 MuiTransferList.js
│       │   └── 📄 MuiTypography.js
│       └── 📁 widgets/                  # Widgets vista
│           ├── 📁 banners/              # Widgets banners
│           │   └── 📄 WidgetBanners.js
│           ├── 📁 cards/                # Widgets tarjetas
│           │   └── 📄 WidgetCards.js
│           └── 📁 charts/               # Widgets gráficos
│               └── 📄 WidgetCharts.js

---

## 🏗️ Arquitectura de Componentes

### 📊 **Aplicaciones Principales**

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
