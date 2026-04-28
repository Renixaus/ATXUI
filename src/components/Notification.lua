--!strict
local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local UserInputService = cloneref(game:GetService("UserInputService"))

local NotificationModule = {
	Size = UDim2.new(0, 300, 1, -100 - 56),
	SizeLower = UDim2.new(0, 300, 1, -56),
	UICorner = 18,
	UIPadding = 14,
	Holder = nil,
	NotificationIndex = 0,
	Notifications = {},
	MaxNotifications = 6, -- Ekranda ayni anda en fazla kac bildirim olabilecegini belirler
}

function NotificationModule.Init(Parent)
	local NotModule = {
		Lower = false,
	}

	function NotModule.SetLower(val)
		NotModule.Lower = val
		NotModule.Frame.Size = val and NotificationModule.SizeLower or NotificationModule.Size
	end

	NotModule.Frame = New("Frame", {
		Position = UDim2.new(1, -116 / 4, 0, 56),
		AnchorPoint = Vector2.new(1, 0),
		Size = NotificationModule.Size,
		Parent = Parent,
		BackgroundTransparency = 1,
	}, {
		New("UIListLayout", {
			HorizontalAlignment = "Right",
			SortOrder = "LayoutOrder",
			VerticalAlignment = "Bottom",
			Padding = UDim.new(0, 8),
		}),
		New("UIPadding", {
			PaddingBottom = UDim.new(0, 116 / 4),
		}),
	})
	return NotModule
end

function NotificationModule.New(Config)
	local Notification = {
		Title = Config.Title or "Notification",
		Content = Config.Content or nil,
		Icon = Config.Icon or nil,
		IconThemed = Config.IconThemed,
		Background = Config.Background,
		BackgroundImageTransparency = Config.BackgroundImageTransparency,
		Duration = Config.Duration or 5,
		Buttons = Config.Buttons or {},
		CanClose = Config.CanClose ~= false,
		UIElements = {},
		Closed = false,
		Id = NotificationModule.NotificationIndex + 1,
	}

	NotificationModule.NotificationIndex = Notification.Id
	table.insert(NotificationModule.Notifications, Notification)

	-- Maksimum bildirim limitini kontrol et ve eskileri kapat
	if #NotificationModule.Notifications > NotificationModule.MaxNotifications then
		local oldestNotification = NotificationModule.Notifications[1]
		if oldestNotification and not oldestNotification.Closed then
			oldestNotification:Close()
		end
	end

	local Icon
	if Notification.Icon then
		Icon = Creator.Image(
			Notification.Icon,
			Notification.Title .. ":" .. Notification.Icon,
			0,
			Config.Window,
			"Notification",
			Notification.IconThemed
		)
		Icon.Size = UDim2.new(0, 26, 0, 26)
		Icon.Position = UDim2.new(0, NotificationModule.UIPadding, 0, NotificationModule.UIPadding)
	end

	local CloseButton
	if Notification.CanClose then
		CloseButton = New("ImageButton", {
			Image = Creator.Icon("x")[1],
			ImageRectSize = Creator.Icon("x")[2].ImageRectSize,
			ImageRectOffset = Creator.Icon("x")[2].ImageRectPosition,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -NotificationModule.UIPadding, 0, NotificationModule.UIPadding),
			AnchorPoint = Vector2.new(1, 0),
			ThemeTag = { ImageColor3 = "Text" },
			ImageTransparency = 0.4,
		}, {
			New("TextButton", {
				Size = UDim2.new(1, 8, 1, 8),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Text = "",
			}),
		})
	end

	local Duration = Creator.NewRoundFrame(NotificationModule.UICorner, "Squircle", {
		Size = UDim2.new(0, 0, 1, 0),
		ThemeTag = {
			ImageTransparency = "NotificationDurationTransparency",
			ImageColor3 = "NotificationDuration",
		},
	})

	local TextContainer = New("Frame", {
		Size = UDim2.new(1, Notification.Icon and -28 - NotificationModule.UIPadding or 0, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		AutomaticSize = "Y",
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, NotificationModule.UIPadding),
			PaddingLeft = UDim.new(0, NotificationModule.UIPadding),
			PaddingRight = UDim.new(0, NotificationModule.UIPadding),
			PaddingBottom = UDim.new(0, NotificationModule.UIPadding),
		}),
		New("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -30 - NotificationModule.UIPadding, 0, 0),
			TextWrapped = true,
			TextXAlignment = "Left",
			RichText = true,
			BackgroundTransparency = 1,
			TextSize = 18,
			ThemeTag = {
				TextColor3 = "NotificationTitle",
				TextTransparency = "NotificationTitleTransparency",
			},
			Text = Notification.Title,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		}),
		New("UIListLayout", { Padding = UDim.new(0, NotificationModule.UIPadding / 3) }),
	})

	if Notification.Content then
		New("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			TextXAlignment = "Left",
			RichText = true,
			BackgroundTransparency = 1,
			TextSize = 15,
			ThemeTag = {
				TextColor3 = "NotificationContent",
				TextTransparency = "NotificationContentTransparency",
			},
			Text = Notification.Content,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			Parent = TextContainer,
		})
	end

	local Main = Creator.NewRoundFrame(NotificationModule.UICorner, "Squircle", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(1.5, 0, 0, 0), -- Sağdan gelecek şekilde başlat
		AutomaticSize = "Y",
		ImageTransparency = 0.05,
		ThemeTag = { ImageColor3 = "Notification" },
	}, {
		Creator.NewRoundFrame(NotificationModule.UICorner, "Glass-1", {
			Size = UDim2.new(1, 0, 1, 0),
			ThemeTag = {
				ImageColor3 = "NotificationBorder",
				ImageTransparency = "NotificationBorderTransparency",
			},
		}),
		New("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Name = "DurationFrame",
		}, {
			New("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
			}, { Duration }),
		}),
		New("ImageLabel", {
			Name = "Background",
			Image = Notification.Background,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ScaleType = "Crop",
			ImageTransparency = Notification.BackgroundImageTransparency,
		}, { New("UICorner", { CornerRadius = UDim.new(0, NotificationModule.UICorner) }) }),
		TextContainer,
		Icon,
		CloseButton,
	})

	local MainContainer = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = false,
		Parent = Config.Holder,
	}, { Main })

	-- Swipe-to-Dismiss (Kaydırarak Kapatma) Mantığı
	local dragging = false
	local dragStart = nil
	local startPos = nil

	Creator.AddSignal(Main.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position.X
			startPos = Main.Position.X.Scale
		end
	end, Main)

	Creator.AddSignal(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local deltaX = input.Position.X - dragStart
			-- Sadece sağa doğru kaydırmaya izin ver (hafifçe sola da gidebilir ama direnç uygula)
			local newX = math.max(0, deltaX / Main.AbsoluteSize.X)
			Main.Position = UDim2.new(newX, 0, 0, 0)
			Main.ImageTransparency = 0.05 + (newX * 0.5) -- Kaydırdıkça şeffaflaş
		end
	end)

	Creator.AddSignal(UserInputService.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			local currentXScale = Main.Position.X.Scale
			
			if currentXScale > 0.4 then
				-- Eğer %40'dan fazla sağa kaydırıldıysa kapat
				Notification:Close(true)
			else
				-- Yeterince kaydırılmadıysa geri yaylan
				Tween(Main, 0.45, { Position = UDim2.new(0, 0, 0, 0), ImageTransparency = 0.05 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			end
		end
	end)

	local isClosing = false

	function Notification:Close(isSwiped)
		if isClosing then return end
		isClosing = true
		Notification.Closed = true

		-- Listeden kaldır
		for i, notif in ipairs(NotificationModule.Notifications) do
			if notif.Id == Notification.Id then
				table.remove(NotificationModule.Notifications, i)
				break
			end
		end

		if isSwiped then
			-- Zaten sağa kaydırıldığı için sadece container'ı küçült ve dışarı kaydır
			Tween(Main, 0.3, { Position = UDim2.new(1.5, 0, 0, 0), ImageTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		else
			-- Normal kapanış, sağa doğru çıkar
			Tween(Main, 0.45, { Position = UDim2.new(1.5, 0, 0, 0), ImageTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		end

		Tween(MainContainer, 0.45, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		
		task.wait(0.45)
		Creator.DisconnectObjectSignals(Main)
		MainContainer:Destroy()
	end

	task.spawn(function()
		task.wait()
		-- Animasyonlu geliş
		Tween(MainContainer, 0.45, { Size = UDim2.new(1, 0, 0, Main.AbsoluteSize.Y) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		Tween(Main, 0.45, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		
		if Notification.Duration then
			Duration.Size = UDim2.new(0, Main.DurationFrame.AbsoluteSize.X, 1, 0)
			Tween(Main.DurationFrame.Frame, Notification.Duration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut):Play()
			task.wait(Notification.Duration)
			if not Notification.Closed then
				Notification:Close()
			end
		end
	end)

	if CloseButton then
		Creator.AddSignal(CloseButton.TextButton.MouseButton1Click, function()
			Notification:Close()
		end, Main)
	end

	return Notification
end

return NotificationModule