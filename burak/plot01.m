clear;
load inresponse.mat
load outresponse.mat

clf
subplot(4,2,1)
plot(linspace(0,550,5500),mapinresponse(1,:),'LineWidth',2)
hold on
plot(linspace(0,550,5500),gminresponse(1,:),'LineWidth',2)
ylim([-3 3])
set(gca,'FontSize',15)

subplot(4,2,2)
plot(linspace(0,550,5500),mapoutresponse(1,:),'LineWidth',2)
hold on
plot(linspace(0,550,5500),gmoutresponse(1,:),'LineWidth',2)
ylim([-3 3])
set(gca,'FontSize',15)


%-----
subplot(4,2,3)
plot(linspace(0,550,5500),mapinresponse(2,:),'LineWidth',2)
hold on
plot(linspace(0,550,5500),gminresponse(2,:),'LineWidth',2)
ylim([-2 2])
set(gca,'FontSize',15)

subplot(4,2,4)
plot(linspace(0,550,5500),mapoutresponse(2,:),'LineWidth',2)
hold on
plot(linspace(0,550,5500),gmoutresponse(2,:),'LineWidth',2)
ylim([-2 2])
set(gca,'FontSize',15)


%-----
subplot(4,2,5)
plot(linspace(0,550,5500),mapinresponse(3,:),'LineWidth',2)
hold on
plot(linspace(0,550,5500),gminresponse(3,:),'LineWidth',2)
ylim([-2 2])
set(gca,'FontSize',15)


subplot(4,2,6)
plot(linspace(0,550,5500),mapoutresponse(3,:),'LineWidth',2)
hold on
plot(linspace(0,550,5500),gmoutresponse(3,:),'LineWidth',2)
ylim([-2 2])
set(gca,'FontSize',15)


%-----
subplot(4,2,7)
plot(linspace(0,550,5500),mapinresponse(4,:),'LineWidth',2)
hold on
plot(linspace(0,550,5500),gminresponse(4,:),'LineWidth',2)
ylim([-2 2])
set(gca,'FontSize',15)

subplot(4,2,8)
plot(linspace(0,550,5500),mapoutresponse(4,:),'LineWidth',2)
hold on
plot(linspace(0,550,5500),gmoutresponse(4,:),'LineWidth',2)
ylim([-2 2])
set(gca,'FontSize',15)

